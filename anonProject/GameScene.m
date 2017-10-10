//
//  GameScene.m
//  anonProject
//
//  Created by Nikolaos Grigoriadis on 7/9/15.
//  Copyright (c) 2015 anon. All rights reserved.
//

#import "GameScene.h"
#import "Card.h"

@implementation GameScene

@synthesize teamAScoreLabel;
@synthesize teamBScoreLabel;
@synthesize deckCardNode;
@synthesize player1Label;
@synthesize player2Label;
@synthesize player3Label;
@synthesize player4Label;
@synthesize scoreLabel;
@synthesize scoreInfoContainer;
@synthesize menuButtonContainer;

-(void)didMoveToView:(SKView *)view
{
    [self setScaleMode:SKSceneScaleModeResizeFill];
    
    deckCardNode = (SKSpriteNode *) [self childNodeWithName:@"deckCard"];
    teamAScoreLabel = (SKLabelNode*)[[self childNodeWithName:@"blackboard"] childNodeWithName:@"team1score"];
    teamBScoreLabel = (SKLabelNode*)[[self childNodeWithName:@"blackboard"] childNodeWithName:@"team2score"];
   
    player1Label = (SKLabelNode*)[self childNodeWithName:@"player1Label"];
    player2Label = (SKLabelNode*)[self childNodeWithName:@"player2Label"];
    player3Label = (SKLabelNode*)[self childNodeWithName:@"player3Label"];
    player4Label = (SKLabelNode*)[self childNodeWithName:@"player4Label"];
    
    scoreLabel = (SKLabelNode*)[self childNodeWithName:@"scoreLabel"];
    [scoreLabel setHidden:YES];
    
    [player1Label setText:@"MorrisSan"];
    [player2Label setText:@"CPU1"];
    [player3Label setText:@"CPU2"];
    [player4Label setText:@"CPU3"];
    
    
    scoreInfoContainer = (SKSpriteNode *) [[self childNodeWithName:@"blackboard"] childNodeWithName:@"scoreInfoContainer"];
//    [scoreInfoContainer setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:10]];
   
    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:CGPointZero
                                                        radius: scoreInfoContainer.frame.size.height/2
                                                    startAngle: 0
                                                      endAngle: M_PI * 2
                                                     clockwise: YES];
    SKShapeNode* circle = [SKShapeNode node];
    circle.path = path.CGPath;
    circle.lineWidth = 2.0;
    circle.fillColor = [UIColor clearColor];
    circle.strokeColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    [scoreInfoContainer addChild:circle];

    
    if(self.numOfPlayers==2)
    {
        [player1Label setPosition:CGPointMake(self.view.frame.size.width/5, [self childNodeWithName:@"deckCard"].frame.size.height)];
        [player2Label setPosition:CGPointMake(self.view.frame.size.width/5, self.view.frame.size.height-[self childNodeWithName:@"deckCard"].frame.size.height)];
        
        [[self childNodeWithName:@"player3Label"] setHidden:YES];
        [[self childNodeWithName:@"player4Label"] setHidden:YES];
    }
    else
    {
        
    }
    
    [self setTeamAScore:0 teamBScore:0];
//    
    SKSpriteNode *blackboard=(SKSpriteNode *)[self childNodeWithName:@"blackboard"];
    [blackboard setPosition:CGPointMake(self.view.frame.size.width-blackboard.frame.size.width/2-20, self.view.frame.size.height-blackboard.frame.size.height/2-10)];
    
    menuButtonContainer = (CustomButton *)[self childNodeWithName:@"menuButtonContainer"];
    [menuButtonContainer initButtonWithType:MenuButton];
    [menuButtonContainer setPosition:CGPointMake(20, self.view.frame.size.height-blackboard.frame.size.height/2-10)];
    
    SKSpriteNode *backgroundNode=(SKSpriteNode *)[self childNodeWithName:@"backgroundNode"];
    [backgroundNode setSize:self.view.frame.size];
    [backgroundNode setPosition:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    
    SKLightNode *light1 = (SKLightNode *)[self childNodeWithName:@"light1"];
    [light1 setPosition:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [deckCardNode setPosition:CGPointMake(self.view.frame.size.width/2+100, self.view.frame.size.height/2)];
    
    self.gameHandler = [GameHandler initGameWithNumberOfPlayers:self.numOfPlayers listener:self];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) {
        
        if([self.view.subviews containsObject:self.menuView]){
            return;
        }
        if([[self nodeAtPoint:[touch locationInNode:self]] isKindOfClass:[CustomButton class]] ){
            
            if(self.menuView == nil) {
                 self.menuView = [GameMenuView initControllerForFrame:self.view.frame listener:self];
                [self.view addSubview:self.menuView];
            } else if(![self.view.subviews containsObject:self.menuView]) {
                [self.view addSubview:self.menuView];
            }
            
        }else if([[self nodeAtPoint:[touch locationInNode:self]] isKindOfClass:[Card class]] ) {
            
            Player *user = [self.gameHandler getUser];
            Card *touchedCard=(Card *)[self nodeAtPoint:[touch locationInNode:self]];
            if(touchedCard.isFocused){//drop card
                for(int i=0;i<[user getPlayerCardListCount];i++) {
                    Card *aCard = [user getPlayerCardAtIndex:i];
                    if(touchedCard.identifier == aCard.identifier) {
                        touchedCard.focused=NO;
                        aCard.focused=NO;
                        [user removePlayerCardAtIndex:i];
                        [self.gameHandler addToCenterCardPile:aCard];
                        [touchedCard setZPosition:[self.gameHandler getCenterCardPileCount]];
                        [touchedCard setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
                        SKAction *dropCard =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
                        [touchedCard runAction:dropCard completion:^{
                            [self.gameHandler checkWin];
                            [self.gameHandler endTurn];
                        }];
                        break;
                    }
                }
            }
            else { //select another card
                Player *user = [self.gameHandler getUser];
                for(int i=0;i<[user getPlayerCardListCount];i++) {
                    
                    Card *aCard=[user getPlayerCardAtIndex:i];
                    if(touchedCard.identifier == aCard.identifier && ![aCard isFocused]){//card not selected
                        
                        touchedCard.focused=YES;
                        aCard.focused=YES;
                        SKAction *focusCard =[SKAction moveTo:CGPointMake(touchedCard.position.x, touchedCard.position.y+40)  duration:0.2];
                        [touchedCard runAction:focusCard];
                    } else if([aCard isFocused]){//if another card is focused
                    
                        Card *focusedCard= (Card *) [self childNodeWithName:aCard.name];
                        focusedCard.focused=NO;
                        aCard.focused=NO;
                        SKAction *focusCard =[SKAction moveTo:CGPointMake(focusedCard.position.x, focusedCard.position.y-40)  duration:0.2];
                        [focusedCard runAction:focusCard];
                        
                    }}}}}
}

-(void) CPUPlays
{
    Card *nodeCard = [self.gameHandler CPUPlay];
    [nodeCard setTexture:[nodeCard getCardTexture]];
    [nodeCard setZPosition:[self.gameHandler getCenterCardPileCount]];
    [nodeCard setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
    SKAction *CPUDrops =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
    SKAction *CPUDropsWait =[SKAction waitForDuration:0.5];
    SKAction *sequence=[SKAction sequence:@[CPUDrops,CPUDropsWait]];
    [nodeCard runAction:sequence completion:^{
        [self.gameHandler checkWin];
        [self.gameHandler endTurn];
    }];
}

-(void) dealToPlayer1 : (GameMode) aGameMode dealtCard : (Card *) dealtCard numOfCards : (NSInteger) numOfCards
{
    SKSpriteNode *deck =(SKSpriteNode *) [self childNodeWithName:@"deckCard"];
    [dealtCard setPosition:deck.position];
    [dealtCard setFocused:NO];
    [dealtCard setZPosition:(CGFloat)numOfCards];
    [dealtCard setScale:0.8];
    [self addChild:dealtCard];
    SKAction *moveAction;
    
    if(aGameMode == TwoPlayerMode) {
        moveAction = [SKAction moveTo:CGPointMake(self.view.frame.size.width/5 + numOfCards*35, 0) duration:0.2];
        
    } else {
        moveAction = [SKAction moveTo:CGPointMake(self.view.frame.size.width/4+numOfCards*35, dealtCard.frame.size.height/2) duration:0.2];
    }
    [dealtCard runAction:moveAction];
}

-(void) dealToPlayer2 : (GameMode) aGameMode dealtCard : (Card *) dealtCard numOfCards : (NSInteger) numOfCards
{
    SKSpriteNode *deck =(SKSpriteNode *) [self childNodeWithName:@"deckCard"];
    [dealtCard setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"b1fv.png"]]];
    [dealtCard setPosition:deck.position];
    [dealtCard setScale:0.8];
    [self addChild:dealtCard];
    [dealtCard setZPosition:(CGFloat)numOfCards];
    [dealtCard setFocused:NO];
    SKAction *moveAction;
    
    if(aGameMode == TwoPlayerMode) {
        moveAction = [SKAction moveTo:CGPointMake(self.view.frame.size.width/5+numOfCards*35, self.view.frame.size.height) duration:0.2];
        
    } else {
        [dealtCard setZRotation:M_PI/2];
        moveAction = [SKAction moveTo:CGPointMake(self.view.frame.size.width/12, (self.view.frame.size.height)/5+numOfCards*20) duration:0.2];
        
    }
    [dealtCard runAction:moveAction];
}

-(void) dealToPlayer3 : (GameMode) aGameMode dealtCard : (Card *) dealtCard numOfCards : (NSInteger) numOfCards
{
    SKSpriteNode *deck =(SKSpriteNode *) [self childNodeWithName:@"deckCard"];
    [dealtCard setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"b1fv.png"]]];
    [dealtCard setPosition:deck.position];
    [dealtCard setScale:0.8];
    [self addChild:dealtCard];
    [dealtCard setZPosition:(CGFloat)numOfCards];
    [dealtCard setFocused:NO];
    SKAction *moveAction = [SKAction moveTo:CGPointMake(self.view.frame.size.width/3.5+numOfCards*20, (6.5*self.view.frame.size.height)/8) duration:0.2];
    [dealtCard runAction:moveAction];
}

-(void) dealToPlayer4 : (GameMode) aGameMode dealtCard : (Card *) dealtCard numOfCards : (NSInteger) numOfCards
{
    SKSpriteNode *deck =(SKSpriteNode *) [self childNodeWithName:@"deckCard"];
    [dealtCard setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"b1fv.png"]]];
    [dealtCard setPosition:deck.position];
    [dealtCard setZRotation:M_PI/2];
    [dealtCard setScale:0.8];
    [self addChild:dealtCard];
    [dealtCard setZPosition:(CGFloat)numOfCards];
    [dealtCard setFocused:NO];
    SKAction *moveAction = [SKAction moveTo:CGPointMake((7*self.view.frame.size.width)/8, (6*self.view.frame.size.height)/8-numOfCards*20) duration:0.2];
    [dealtCard runAction:moveAction];
}

-(void) dealMiddle    : (GameMode) aGameMode dealtCard : (Card *) dealtCard
{
    SKSpriteNode *deck =(SKSpriteNode *) [self childNodeWithName:@"deckCard"];
    [dealtCard setPosition:deck.position];
    [dealtCard setFocused:NO];
    [dealtCard setScale:0.8];
    [self addChild:dealtCard];
    [dealtCard setZPosition:(CGFloat)[self.gameHandler getCenterCardPileCount]];
    [dealtCard setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
    SKAction *moveAction = [SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2) duration:0.2];
    [dealtCard runAction:moveAction];
}

-(void) player1GathersCards : (GameMode) aGameMode
{
    SKAction *moveToPlayer =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, 0-self.view.frame.size.height)  duration:0.5];
    [self commonGatherBlockWithAction:moveToPlayer:YES];
}

-(void) player2GathersCards : (GameMode) aGameMode
{
    SKAction *moveToPlayer;
    if(aGameMode == TwoPlayerMode) {
        moveToPlayer =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, 2*self.view.frame.size.height)  duration:0.5];
    } else {
        moveToPlayer =[SKAction moveTo:CGPointMake(0-self.view.frame.size.width, self.view.frame.size.height/2)  duration:0.5];
    }
    [self commonGatherBlockWithAction:moveToPlayer:NO];
}

-(void) player3GathersCards : (GameMode) aGameMode
{
    SKAction *moveToPlayer =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, 2*self.view.frame.size.height)  duration:0.5];
    [self commonGatherBlockWithAction:moveToPlayer:YES];
}

-(void) player4GathersCards : (GameMode) aGameMode
{
    SKAction *moveToPlayer =[SKAction moveTo:CGPointMake(2*self.view.frame.size.width, self.view.frame.size.height/2)  duration:0.5];
    [self commonGatherBlockWithAction:moveToPlayer:NO];
}

-(void) commonGatherBlockWithAction : (SKAction *) anAction : (BOOL) isOwnTeam
{
    NSInteger pointsTemp = [self calcPointsTemp:self.gameHandler.gameDeck.centerCardPileList];
    if(pointsTemp > 0){
        [scoreLabel setText:[NSString stringWithFormat:@"+%ld Points",(long)pointsTemp]];
        if(isOwnTeam) {
            [scoreLabel setFontColor:[UIColor whiteColor]];
        } else {
            [scoreLabel setFontColor:[UIColor colorWithRed:200.0/255.0 green:50.0/255.0 blue:20.0/255.0 alpha:1.0]];
        }
        [scoreLabel setPosition:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
        [scoreLabel setZPosition:100.0];
        [scoreLabel setHidden:NO];
        SKAction *moveAction = [SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 + 50) duration:1.0];
        [scoreLabel runAction:moveAction completion:^{
            [scoreLabel setHidden:YES];
        }];
    }
    
    while ([self.gameHandler getCenterCardPileCount]!=0)
    {
        Card *aCard = [self.gameHandler getCenterCardPileBottomCard];
        [[self childNodeWithName:aCard.name] runAction:anAction completion:^{
            
            [aCard removeFromParent];
        }];
        [self.gameHandler addCardFromPileToPlayer:aCard];
        [self.gameHandler removeCenterCardPileBottomCard];
    }
}

-(NSInteger) calcPointsTemp : (NSMutableArray *) cardArray
{
    NSInteger pointsTemp = 0;
    for (Card *aCard in cardArray) {
        pointsTemp += aCard.pointsWorth;
    }
    
    if([cardArray count] == 2 ) {
        Card *firstCard = [cardArray objectAtIndex:0];
        Card *secondCard = [cardArray objectAtIndex:1];
        if(firstCard.number == secondCard.number) {
            pointsTemp += (firstCard.number == 11 && secondCard.number == 1)?20:10;
        }
    }
    return pointsTemp;
}

-(void) removeLastCardOnDeck
{
    [deckCardNode setHidden:YES];
}

-(void) prepareUIForNewRound
{
    [deckCardNode setHidden:NO];
}

-(void) setTeamAScore : (NSInteger) teamAscore teamBScore : (NSInteger) teamBscore
{
    [self.teamAScoreLabel setText:[NSString stringWithFormat:@"%ld",(long)teamAscore]];
    [self.teamBScoreLabel setText:[NSString stringWithFormat:@"%ld",(long)teamBscore]];
}

-(void) userSelectedOption : (MenuOption) anOption
{
    switch (anOption) {
        case ResumeOption:
            
            if([self.view.subviews containsObject:self.menuView]) {
                [self.menuView removeFromSuperview];
            }
            
            break;
            
        case ExitOption:
            
            if([self.view.subviews containsObject:self.menuView]) {
                [self.menuView removeFromSuperview];
                if(self.navigationDelegate != nil){
                    [self removeFromParent];
                    [self.view presentScene:nil];
                    [self.navigationDelegate exitGame];
                }
            }
            
            break;
            
        default:
            break;
    }
}

-(void)update:(CFTimeInterval)currentTime
{
    
}

@end
