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


-(void)didMoveToView:(SKView *)view
{
    SKSpriteNode *sprite2 =(SKSpriteNode *) [self childNodeWithName:@"deckCard"];
    
    if(self.numOfPlayers==2)
    {
        SKLabelNode *player1Label=(SKLabelNode *)[self childNodeWithName:@"player1Label"];
        [player1Label setText:@"Morris_San"];
        [player1Label setPosition:CGPointMake(self.view.frame.size.width/5, [self childNodeWithName:@"deckCard"].frame.size.height)];
        SKLabelNode *player2Label=(SKLabelNode *)[self childNodeWithName:@"player2Label"];
        [player2Label setText:@"CPU"];
        [player2Label setPosition:CGPointMake(self.view.frame.size.width/5, self.view.frame.size.height-[self childNodeWithName:@"deckCard"].frame.size.height)];
        
        [[self childNodeWithName:@"player3Label"] setHidden:YES];
        [[self childNodeWithName:@"player4Label"] setHidden:YES];
    }
    else
    {
        
    }
    
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
    
    self.cardCounter=0;
    self.startNewHand=NO;
    
    [sprite2 setPosition:CGPointMake(self.view.frame.size.width/2+100, self.view.frame.size.height/2)];
    
    self.imageForCardNameDict=[[NSMutableDictionary alloc] init];
    self.gameStart=YES;
    self.playsNowIndex=1;
    self.gameDeck = [Deck initDeck];
    self.gameHandler = [GameHandler initGameWithNumberOfPlayers:self.numOfPlayers gameDeck:self.gameDeck listener:self];
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
                        [touchedCard setZPosition:[self.gameDeck getCenterCardPileCount]];
                        [touchedCard setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
                        SKAction *dropCard =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
                        [touchedCard runAction:dropCard completion:^{
                            [user removePlayerCardAtIndex:i];
                            [self.gameDeck addToCenterCardPileCard:aCard];
                            [self.gameHandler checkWinWithDeck:self.gameDeck];
                            [self.gameHandler endTurn : self.gameDeck];
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
    Card *nodeCard = [self.gameHandler CPUPlayWithDeck:self.gameDeck];
    [nodeCard setTexture:[nodeCard getCardTexture]];
    [nodeCard setZPosition:[self.gameDeck getCenterCardPileCount]];
    [nodeCard setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
    SKAction *CPUDrops =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
    SKAction *CPUDropsWait =[SKAction waitForDuration:0.5];
    SKAction *sequence=[SKAction sequence:@[CPUDrops,CPUDropsWait]];
    [nodeCard runAction:sequence completion:^{
        [self.gameHandler checkWinWithDeck:self.gameDeck];
        [self.gameHandler endTurn : self.gameDeck];
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
    [dealtCard setZRotation:M_PI/2];
    [dealtCard setFocused:NO];
    SKAction *moveAction;
    
    if(aGameMode == TwoPlayerMode) {
        moveAction = [SKAction moveTo:CGPointMake(self.view.frame.size.width/5+numOfCards*35, self.view.frame.size.height) duration:0.2];
        
    } else {
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
    [dealtCard setZPosition:(CGFloat)[self.gameDeck getCenterCardPileCount]];
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
    while ([self.gameDeck getCenterCardPileCount]!=0)
    {
        Card *aCard = [self.gameDeck getCenterCardPileBottomCard];
        [[self childNodeWithName:aCard.name] runAction:anAction];
        [self.gameHandler addCardFromPileToPlayer:aCard];
        [self.gameDeck removeCenterCardPileBottomCard];
    }
}

-(void) removeLastCardOnDeck
{
    [self removeChildrenInArray:@[[self childNodeWithName:@"deckCard"]]];
}

-(void)update:(CFTimeInterval)currentTime
{
    
}

@end
