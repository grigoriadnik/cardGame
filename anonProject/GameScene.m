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

-(void)didMoveToView:(SKView *)view
{
    deckCardNode = (SKSpriteNode *) [self childNodeWithName:@"deckCard"];
    
    teamAScoreLabel = (SKLabelNode*)[[self childNodeWithName:@"blackboard"] childNodeWithName:@"team1score"];
    teamBScoreLabel = (SKLabelNode*)[[self childNodeWithName:@"blackboard"] childNodeWithName:@"team2score"];
   
    player1Label = (SKLabelNode*)[self childNodeWithName:@"player1Label"];
    player2Label = (SKLabelNode*)[self childNodeWithName:@"player2Label"];
    player3Label = (SKLabelNode*)[self childNodeWithName:@"player3Label"];
    player4Label = (SKLabelNode*)[self childNodeWithName:@"player4Label"];
    
    [player1Label setText:@"MorrisSan"];
    [player2Label setText:@"CPU1"];
    [player3Label setText:@"CPU2"];
    [player4Label setText:@"CPU3"];
    
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
    
    SKSpriteNode *blackboard=(SKSpriteNode *)[self childNodeWithName:@"blackboard"];
    [blackboard setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"blackboard2.jpg"]]];
    [blackboard setPosition:CGPointMake(self.view.frame.size.width-blackboard.frame.size.width/2-20, self.view.frame.size.height-blackboard.frame.size.height/2-20)];
    
    SKSpriteNode *menuBar= (SKSpriteNode *)[self childNodeWithName:@"menuBar"];
    [menuBar setSize:CGSizeMake(self.view.frame.size.width, 20)];
    [menuBar setPosition:CGPointMake(0, self.view.frame.size.height-10)];
    
    
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
        
        if([[self nodeAtPoint:[touch locationInNode:self]] isKindOfClass:[Card class]] ) {
            
            Player *user = [self.gameHandler getUser];
            Card *touchedCard=(Card *)[self nodeAtPoint:[touch locationInNode:self]];
            if(touchedCard.isFocused){//drop card
                for(int i=0;i<[user getPlayerCardListCount];i++) {
                    Card *aCard = [user getPlayerCardAtIndex:i];
                    if(touchedCard.identifier == aCard.identifier) {
                        touchedCard.focused=NO;
                        aCard.focused=NO;
                        [touchedCard setZPosition:[self.gameHandler getCenterCardPileCount]];
                        [touchedCard setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
                        SKAction *dropCard =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
                        [touchedCard runAction:dropCard completion:^{
                            [user removePlayerCardAtIndex:i];
                            [self.gameHandler addToCenterCardPile:aCard];
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
                    }
                    else if([aCard isFocused]){//if another card is focused
                    
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
    [self commonGatherBlockWithAction:moveToPlayer];
}

-(void) player2GathersCards : (GameMode) aGameMode
{
    SKAction *moveToPlayer;
    if(aGameMode == TwoPlayerMode) {
        moveToPlayer =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, 2*self.view.frame.size.height)  duration:0.5];
    } else {
        moveToPlayer =[SKAction moveTo:CGPointMake(0-self.view.frame.size.width, self.view.frame.size.height/2)  duration:0.5];
    }
    [self commonGatherBlockWithAction:moveToPlayer];
}

-(void) player3GathersCards : (GameMode) aGameMode
{
    SKAction *moveToPlayer =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, 2*self.view.frame.size.height)  duration:0.5];
    [self commonGatherBlockWithAction:moveToPlayer];
}

-(void) player4GathersCards : (GameMode) aGameMode
{
    SKAction *moveToPlayer =[SKAction moveTo:CGPointMake(2*self.view.frame.size.width, self.view.frame.size.height/2)  duration:0.5];
    [self commonGatherBlockWithAction:moveToPlayer];
}

-(void) commonGatherBlockWithAction : (SKAction *) anAction
{
    while ([self.gameHandler getCenterCardPileCount]!=0)
    {
        Card *aCard = [self.gameHandler getCenterCardPileBottomCard];
        [[self childNodeWithName:aCard.name] runAction:anAction];
        [self.gameHandler addCardFromPileToPlayer:aCard];
        [self.gameHandler removeCenterCardPileBottomCard];
    }
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

-(void)update:(CFTimeInterval)currentTime
{
    
}

@end
