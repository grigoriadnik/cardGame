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
    if(self.numOfPlayers==2)
        self.aTimer=[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(dealCards2Players) userInfo:nil repeats:YES];
    else
        self.aTimer=[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(dealCards4Players) userInfo:nil repeats:YES];
    
    self.imageForCardNameDict=[[NSMutableDictionary alloc] init];
    self.gameStart=YES;
    self.playsNowIndex=1;
    self.player1 = [Player initPlayerWithIndex];
    self.player2 = [Player initPlayerWithIndex];
    self.player3 = [Player initPlayerWithIndex];
    self.player4 = [Player initPlayerWithIndex];
    self.gameDeck = [Deck initDeck];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches)
    {
        if([[self nodeAtPoint:[touch locationInNode:self]] isKindOfClass:[Card class]] )
        {
            Card *touchedCard=(Card *)[self nodeAtPoint:[touch locationInNode:self]];
            if(touchedCard.isFocused)//drop card
            {
                for(int i=0;i<[self.player1 getPlayerCardListCount];i++)
                {
                    Card *aCard = [self.player1 getPlayerCardAtIndex:i];
                    if(touchedCard.identifier == aCard.identifier)
                    {
                        touchedCard.focused=NO;
                        aCard.focused=NO;
                        [touchedCard setZPosition:[self.gameDeck getCenterCardPileCount]];
                        [touchedCard setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
                        SKAction *dropCard =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
                        [touchedCard runAction:dropCard completion:^{
                            [self.player1 removePlayerCardAtIndex:i];
                            [self.gameDeck addToCenterCardPileCard:aCard];
                            [self checkWin];
                             self.playsNowIndex=2;
                            if([self.player1 getPlayerCardListCount]==0 && [self.player2 getPlayerCardListCount]==0 && [self.player3 getPlayerCardListCount]==0 && [self.player4 getPlayerCardListCount]==0)
                                [self checkNewHand];
                            else
                                [self CPUPlays];
                        }];
                        break;
                    }
                }
            }
            else//select another card
            {
                for(int i=0;i<[self.player1 getPlayerCardListCount];i++)
                {
                    Card *aCard=[self.player1 getPlayerCardAtIndex:i];
                    if(touchedCard.identifier == aCard.identifier && ![aCard isFocused])//card not selected
                    {
                        touchedCard.focused=YES;
                        aCard.focused=YES;
//                        [self.playerCardsList replaceObjectAtIndex:i withObject:aCard];
                        SKAction *focusCard =[SKAction moveTo:CGPointMake(touchedCard.position.x, touchedCard.position.y+40)  duration:0.2];
                        [touchedCard runAction:focusCard];
                    }
                    else if([aCard isFocused])//if another card is focused
                    {
                        Card *focusedCard= (Card *) [self childNodeWithName:aCard.name];
                        focusedCard.focused=NO;
                        aCard.focused=NO;
                        SKAction *focusCard =[SKAction moveTo:CGPointMake(focusedCard.position.x, focusedCard.position.y-40)  duration:0.2];
                        [focusedCard runAction:focusCard];
//                        [self.playerCardsList replaceObjectAtIndex:i withObject:aCard];
                    }
                }
            }
        }
    }
}

-(void) CPUPlays
{
    NSInteger cardIndex=0;
    if([self.gameDeck getCenterCardPileCount] != 0)
    {
        Card *topCard=[self.gameDeck getCenterCardPileTopCard];
        switch (self.playsNowIndex)
        {
            case 2:
            {
                cardIndex = [self.player2 getIndexForCardNumber:topCard.number];
                Card *originalCard= [self.player2 getPlayerCardAtIndex:cardIndex];
                Card *cardToBeDroped = (Card *) [self childNodeWithName:originalCard.name];
                [cardToBeDroped setTexture:[SKTexture textureWithImage:[UIImage imageNamed:[self.imageForCardNameDict objectForKey:cardToBeDroped.name]]]];
                [cardToBeDroped setZPosition:[self.gameDeck getCenterCardPileCount]];
                [cardToBeDroped setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
                [self.gameDeck addToCenterCardPileCard:[self.player2 getPlayerCardAtIndex:cardIndex]];
                [self.player2 removePlayerCardAtIndex:cardIndex];
                SKAction *CPUDrops =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
                SKAction *CPUDropsWait =[SKAction waitForDuration:0.5];
                SKAction *sequence=[SKAction sequence:@[CPUDrops,CPUDropsWait]];
                [cardToBeDroped runAction:sequence completion:^{
                    [self checkWin];
                    if(self.numOfPlayers==2)
                    {
                        self.playsNowIndex=1;
                        if([self.player1 getPlayerCardListCount]==0 && [self.player2 getPlayerCardListCount]==0 && [self.player3 getPlayerCardListCount]==0 && [self.player4 getPlayerCardListCount]==0)
                            [self checkNewHand];
                    }
                    else
                    {
                        self.playsNowIndex++;
                        if([self.player1 getPlayerCardListCount]==0 && [self.player2 getPlayerCardListCount]==0 && [self.player3 getPlayerCardListCount]==0 && [self.player4 getPlayerCardListCount]==0)
                            [self checkNewHand];
                        else
                            [self CPUPlays];
                    }
                }];
                break;
            }
            case 3:
            {
                cardIndex = [self.player3 getIndexForCardNumber:topCard.number];
                Card *originalCard= [self.player3 getPlayerCardAtIndex:cardIndex];
                Card *cardToBeDroped = (Card *) [self childNodeWithName:originalCard.name];
                [cardToBeDroped setTexture:[SKTexture textureWithImage:[UIImage imageNamed:[self.imageForCardNameDict objectForKey:cardToBeDroped.name]]]];
                [cardToBeDroped setZPosition:[self.gameDeck getCenterCardPileCount]];
                [cardToBeDroped setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
                [self.gameDeck addToCenterCardPileCard:[self.player3 getPlayerCardAtIndex:cardIndex]];
                [self.player3 removePlayerCardAtIndex:cardIndex];
                SKAction *CPUDrops =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
                SKAction *CPUDropsWait =[SKAction waitForDuration:0.5];
                SKAction *sequence=[SKAction sequence:@[CPUDrops,CPUDropsWait]];
                [cardToBeDroped runAction:sequence completion:^{
                    [self checkWin];
                    self.playsNowIndex++;
                    if([self.player1 getPlayerCardListCount]==0 && [self.player2 getPlayerCardListCount]==0 && [self.player3 getPlayerCardListCount]==0 && [self.player4 getPlayerCardListCount]==0)
                        [self checkNewHand];
                    else
                        [self CPUPlays];
                }];
                break;
            }
            case 4:
            {
                cardIndex = [self.player4 getIndexForCardNumber:topCard.number];
                Card *originalCard= [self.player4 getPlayerCardAtIndex:cardIndex];
                Card *cardToBeDroped = (Card *) [self childNodeWithName:originalCard.name];
                [cardToBeDroped setTexture:[SKTexture textureWithImage:[UIImage imageNamed:[self.imageForCardNameDict objectForKey:cardToBeDroped.name]]]];
                [cardToBeDroped setZPosition:[self.gameDeck getCenterCardPileCount]];
                [cardToBeDroped setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
                [self.gameDeck addToCenterCardPileCard:[self.player4 getPlayerCardAtIndex:cardIndex]];
                [self.player4 removePlayerCardAtIndex:cardIndex];
                SKAction *CPUDrops =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
                SKAction *CPUDropsWait =[SKAction waitForDuration:0.5];
                SKAction *sequence=[SKAction sequence:@[CPUDrops,CPUDropsWait]];
                [cardToBeDroped runAction:sequence completion:^{
                    [self checkWin];
                    self.playsNowIndex=1;
                    if([self.player1 getPlayerCardListCount]==0 && [self.player2 getPlayerCardListCount]==0 && [self.player3 getPlayerCardListCount]==0 && [self.player4 getPlayerCardListCount]==0)
                        [self checkNewHand];
                    else
                        [self CPUPlays];
                }];
                break;
            }
            default:
                break;
        }
    }
    else
    {
        switch (self.playsNowIndex)
        {
            case 2:
            {
                Card *originalCard= [self.player2 getPlayerCardAtIndex:cardIndex];
                Card *cardToBeDroped = (Card *) [self childNodeWithName:originalCard.name];
                [cardToBeDroped setTexture:[SKTexture textureWithImage:[UIImage imageNamed:[self.imageForCardNameDict objectForKey:cardToBeDroped.name]]]];
                [cardToBeDroped setZPosition:[self.gameDeck getCenterCardPileCount]];
                [cardToBeDroped setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
                [self.gameDeck addToCenterCardPileCard:[self.player2 getPlayerCardAtIndex:cardIndex]];
                [self.player2 removePlayerCardAtIndex:cardIndex];
                SKAction *CPUDrops =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
                SKAction *CPUDropsWait =[SKAction waitForDuration:0.5];
                SKAction *sequence=[SKAction sequence:@[CPUDrops,CPUDropsWait]];
                [cardToBeDroped runAction:sequence completion:^{
                    if(self.numOfPlayers==2)
                    {
                        self.playsNowIndex=1;
                        if([self.player1 getPlayerCardListCount]==0 && [self.player2 getPlayerCardListCount]==0 && [self.player3 getPlayerCardListCount]==0 && [self.player4 getPlayerCardListCount]==0)
                            [self checkNewHand];
                    }
                    else
                    {
                        self.playsNowIndex++;
                        if([self.player1 getPlayerCardListCount]==0 && [self.player2 getPlayerCardListCount]==0 && [self.player3 getPlayerCardListCount]==0 && [self.player4 getPlayerCardListCount]==0)
                            [self checkNewHand];
                        else
                            [self CPUPlays];
                    }
                }];
                break;
            }
            case 3:
            {
                Card *originalCard= [self.player3 getPlayerCardAtIndex:cardIndex];
                Card *cardToBeDroped = (Card *) [self childNodeWithName:originalCard.name];
                [cardToBeDroped setTexture:[SKTexture textureWithImage:[UIImage imageNamed:[self.imageForCardNameDict objectForKey:cardToBeDroped.name]]]];
                [cardToBeDroped setZPosition:[self.gameDeck getCenterCardPileCount]];
                [cardToBeDroped setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
                [self.gameDeck addToCenterCardPileCard:[self.player3 getPlayerCardAtIndex:cardIndex]];
                [self.player3 removePlayerCardAtIndex:cardIndex];
                SKAction *CPUDrops =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
                SKAction *CPUDropsWait =[SKAction waitForDuration:0.5];
                SKAction *sequence=[SKAction sequence:@[CPUDrops,CPUDropsWait]];
                [cardToBeDroped runAction:sequence completion:^{
                    self.playsNowIndex++;
                    if([self.player1 getPlayerCardListCount]==0 && [self.player2 getPlayerCardListCount]==0 && [self.player3 getPlayerCardListCount]==0 && [self.player4 getPlayerCardListCount]==0)
                        [self checkNewHand];
                    else
                        [self CPUPlays];
                }];
                break;
            }
            case 4:
            {
                Card *originalCard= [self.player4 getPlayerCardAtIndex:cardIndex];
                Card *cardToBeDroped = (Card *) [self childNodeWithName:originalCard.name];
                [cardToBeDroped setTexture:[SKTexture textureWithImage:[UIImage imageNamed:[self.imageForCardNameDict objectForKey:cardToBeDroped.name]]]];
                [cardToBeDroped setZPosition:[self.gameDeck getCenterCardPileCount]];
                [cardToBeDroped setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
                [self.gameDeck addToCenterCardPileCard:[self.player4 getPlayerCardAtIndex:cardIndex]];
                [self.player4 removePlayerCardAtIndex:cardIndex];
                SKAction *CPUDrops =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
                SKAction *CPUDropsWait =[SKAction waitForDuration:0.5];
                SKAction *sequence=[SKAction sequence:@[CPUDrops,CPUDropsWait]];
                [cardToBeDroped runAction:sequence];
                self.playsNowIndex=1;
                if([self.player1 getPlayerCardListCount]==0 && [self.player2 getPlayerCardListCount]==0 && [self.player3 getPlayerCardListCount]==0 && [self.player4 getPlayerCardListCount]==0)
                    [self checkNewHand];
                break;
            }
            default:
                break;
        }
    }

}

-(void) checkWin
{
    if([self.gameDeck getCenterCardPileCount]<2)
        return;
    
    Card *topCard = [self.gameDeck getCenterCardPileTopCard];
    Card *secondTopCard = [self.gameDeck getCenterCardPileSecondTopCard];
    
    if(topCard.number==11 || topCard.number==secondTopCard.number)//wins hand
    {
//        NSLog(@"win %d vs %d",topCard.number,secondTopCard.number);
        SKAction *moveToPlayer;
        if(self.playsNowIndex==1)//player down
            moveToPlayer =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, 0-self.view.frame.size.height)  duration:0.5];
        else if(self.playsNowIndex==2)//CPU left OR up
            if(self.numOfPlayers==4)
                moveToPlayer =[SKAction moveTo:CGPointMake(0-self.view.frame.size.width, self.view.frame.size.height/2)  duration:0.5];
            else
                moveToPlayer =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, 2*self.view.frame.size.height)  duration:0.5];
        else if(self.playsNowIndex==3)//up
            moveToPlayer =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, 2*self.view.frame.size.height)  duration:0.5];
        else//right
            moveToPlayer =[SKAction moveTo:CGPointMake(2*self.view.frame.size.width, self.view.frame.size.height/2)  duration:0.5];
        
        while ([self.gameDeck getCenterCardPileCount]!=0)
        {
            Card *aCard = [self.gameDeck getCenterCardPileBottomCard];
            [[self childNodeWithName:aCard.name] runAction:moveToPlayer];
            if(self.playsNowIndex==1)//player wins hand
                [self.player1 addToPlayerGatheredCards:aCard];
            else if(self.playsNowIndex==2)
                [self.player2 addToPlayerGatheredCards:aCard];
            else if(self.playsNowIndex==3)
                [self.player3 addToPlayerGatheredCards:aCard];
            else
                [self.player4 addToPlayerGatheredCards:aCard];
            [self.gameDeck removeCenterCardPileBottomCard];
        }
    }
}

-(void) dealCards2Players
{
    self.cardCounter++;
    if(self.cardCounter<=12)
    {
        SKSpriteNode *deck =(SKSpriteNode *) [self childNodeWithName:@"deckCard"];
        
        switch (self.playsNowIndex) {
            case 1:
            {
                Card *newCard= [self.gameDeck getTopCard];
                [newCard setPosition:deck.position];
                [newCard setFocused:NO];
                [newCard setZPosition:(CGFloat)[self.player1 getPlayerCardListCount]];
                [newCard setScale:0.8];
                //[newCard setLightingBitMask:1];
                [self addChild:newCard];
                [self.player1 addToPlayerCards:newCard];
//                [self.deck removeObjectAtIndex:0];
                SKAction *moveAction = [SKAction moveTo:CGPointMake(self.view.frame.size.width/5+[self.player1 getPlayerCardListCount]*35, 0) duration:0.2];
                [newCard runAction:moveAction];
                self.playsNowIndex++;
                break;
            }
            case 2:
            {
                Card *newCard= [self.gameDeck getTopCard];
                [newCard setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"b1fv.png"]]];
                [newCard setPosition:deck.position];
                [newCard setScale:0.8];
                //[newCard setLightingBitMask:1];
                [self addChild:newCard];
                [newCard setZPosition:(CGFloat)[self.player2 getPlayerCardListCount]];
                [newCard setFocused:NO];
                [self.player2 addToPlayerCards:newCard];
//                [self.deck removeObjectAtIndex:0];
                SKAction *moveAction2 = [SKAction moveTo:CGPointMake(self.view.frame.size.width/5+[self.player2 getPlayerCardListCount]*35, self.view.frame.size.height) duration:0.2];
                [newCard runAction:moveAction2];
                self.playsNowIndex=1;
                break;
            }
            default:
                break;
        }
    }
    else if(self.cardCounter>12 && self.cardCounter<=16 && self.gameStart)
    {
        Card *centerCard=[self.gameDeck getTopCard];
        SKSpriteNode *deck =(SKSpriteNode *) [self childNodeWithName:@"deckCard"];
        [centerCard setPosition:deck.position];
        [centerCard setFocused:NO];
        [centerCard setScale:0.8];
        //[centerCard setLightingBitMask:1];
        [self addChild:centerCard];
        [self.gameDeck addToCenterCardPileCard:[self.gameDeck getTopCard]];
        [centerCard setZPosition:[self.gameDeck getCenterCardPileCount]];
        [centerCard setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
        SKAction *moveAction = [SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2) duration:0.2];
        [centerCard runAction:moveAction];
    }
    else
    {
        self.startNewHand=NO;
        [self.aTimer invalidate];
    }
    
    if(self.cardCounter==16 && self.gameStart)
        self.gameStart=false;
    if([self.gameDeck getDeckCount]==0)
        [self removeChildrenInArray:@[[self childNodeWithName:@"deckCard"]]];
}

-(void) dealCards4Players
{
    self.cardCounter++;
    NSLog(@"card counter %d",self.cardCounter);
    if(self.cardCounter<=24)
    {
        SKSpriteNode *deck =(SKSpriteNode *) [self childNodeWithName:@"deckCard"];
        
        switch (self.playsNowIndex)
        {
            case 1://down
            {
                Card *newCard= [self.gameDeck getTopCard];
                [newCard setPosition:deck.position];
                [newCard setFocused:NO];
                [newCard setZPosition:(CGFloat)[self.player1 getPlayerCardListCount]];
                [newCard setScale:0.8];
                //[newCard setLightingBitMask:1];
                [self addChild:newCard];
                [self.player1 addToPlayerCards:newCard];
                SKAction *moveAction = [SKAction moveTo:CGPointMake(self.view.frame.size.width/4+[self.player1 getPlayerCardListCount]*35, newCard.frame.size.height/2) duration:0.2];
                [newCard runAction:moveAction];
                self.playsNowIndex++;
                break;
            }
            case 2://left
            {
                Card *newCard= [self.gameDeck getTopCard];
                [newCard setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"b1fv.png"]]];
                [newCard setPosition:deck.position];
                [newCard setScale:0.8];
                //[newCard setLightingBitMask:1];
                [self addChild:newCard];
                [newCard setZPosition:(CGFloat)[self.player2 getPlayerCardListCount]];
                [newCard setZRotation:M_PI/2];
                [newCard setFocused:NO];
                [self.player2 addToPlayerCards:newCard];
                SKAction *moveAction2 = [SKAction moveTo:CGPointMake(self.view.frame.size.width/12, (self.view.frame.size.height)/5+[self.player2 getPlayerCardListCount]*20) duration:0.2];
                [newCard runAction:moveAction2];
                self.playsNowIndex++;
                break;
            }
            case 3://up
            {
                Card *newCard= [self.gameDeck getTopCard];
                [newCard setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"b1fv.png"]]];
                [newCard setPosition:deck.position];
                [newCard setScale:0.8];
                //[newCard setLightingBitMask:1];
                [self addChild:newCard];
                [newCard setZPosition:(CGFloat)[self.player3 getPlayerCardListCount]];
                [newCard setFocused:NO];
                [self.player3 addToPlayerCards:newCard];
                SKAction *moveAction = [SKAction moveTo:CGPointMake(self.view.frame.size.width/3.5+[self.player3 getPlayerCardListCount]*20, (6.5*self.view.frame.size.height)/8) duration:0.2];
                [newCard runAction:moveAction];
                self.playsNowIndex++;
                break;
            }
            case 4://right
            {
                Card *newCard= [self.gameDeck getTopCard];
                [newCard setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"b1fv.png"]]];
                [newCard setPosition:deck.position];
                [newCard setZRotation:M_PI/2];
                [newCard setScale:0.8];
                //[newCard setLightingBitMask:1];
                [self addChild:newCard];
                [newCard setZPosition:(CGFloat)[self.player4 getPlayerCardListCount]];
                [newCard setFocused:NO];
                [self.player4 addToPlayerCards:newCard];
                SKAction *moveAction = [SKAction moveTo:CGPointMake((7*self.view.frame.size.width)/8, (6*self.view.frame.size.height)/8-[self.player4 getPlayerCardListCount]*20) duration:0.2];
                [newCard runAction:moveAction];
                self.playsNowIndex=1;
                break;
            }
            default:
                break;
        }
    }
    else if(self.cardCounter>24 && self.cardCounter<=28 && self.gameStart)
    {
        Card *centerCard = [self.gameDeck getTopCard];
        SKSpriteNode *deck =(SKSpriteNode *) [self childNodeWithName:@"deckCard"];
        [centerCard setPosition:deck.position];
        [centerCard setFocused:NO];
        [centerCard setScale:0.8];
        //[centerCard setLightingBitMask:1];
        [self addChild:centerCard];
        [self.gameDeck addToCenterCardPileCard:centerCard];
        [centerCard setZPosition:[self.gameDeck getCenterCardPileCount]];
        [centerCard setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
        SKAction *moveAction = [SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2) duration:0.2];
        [centerCard runAction:moveAction];
    }
    else
    {
        NSLog(@"invalidate timer");
        self.startNewHand=NO;
        [self.aTimer invalidate];
    }
    
    if(self.cardCounter==28 && self.gameStart)
        self.gameStart=false;
    if([self.gameDeck getDeckCount]==0)
    {
        NSLog(@"remove deck card");
        @try {
            [self removeChildrenInArray:@[[self childNodeWithName:@"deckCard"]]];
        }
        @catch (NSException *exception) {
            NSLog(@"deck card exception %@",[exception description]);
        }

        NSLog(@"deck card removed");
    }
}

-(void) checkNewHand
{
    NSLog(@"start dealing");
    if([self.gameDeck getDeckCount]!=0)
    {
        self.cardCounter=0;
        if(self.numOfPlayers==2)
            self.aTimer=[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(dealCards2Players) userInfo:nil repeats:YES];
        else
            self.aTimer=[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(dealCards4Players) userInfo:nil repeats:YES];
        self.startNewHand=YES;
    }
    else
    {
        NSLog(@"end game");
    }
}

-(void)update:(CFTimeInterval)currentTime
{
    
}

@end
