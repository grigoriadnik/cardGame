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
    
    self.playerCardsList=[[NSMutableArray alloc] init];
    self.oppenent1CardsList=[[NSMutableArray alloc] init];
    self.oppenent2CardsList=[[NSMutableArray alloc] init];
    self.oppenent3CardsList=[[NSMutableArray alloc] init];
    self.oppenent1GatheredCardsList=[[NSMutableArray alloc] init];
    self.oppenent2GatheredCardsList=[[NSMutableArray alloc] init];
    self.oppenent3GatheredCardsList=[[NSMutableArray alloc] init];
    self.centerCardPileList=[[NSMutableArray alloc] init];
    self.imageForCardNameDict=[[NSMutableDictionary alloc] init];
    self.playerGatheredCardsList=[[NSMutableArray alloc] init];
    self.gameStart=true;
    self.playsNowIndex=1;
    [self buildDeck];
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
                for(int i=0;i<[self.playerCardsList count];i++)
                {
                    Card *aCard=[self.playerCardsList objectAtIndex:i];
                    if([touchedCard.name isEqualToString:aCard.name])
                    {
                        touchedCard.focused=NO;
                        aCard.focused=NO;
                        [touchedCard setZPosition:[self.centerCardPileList count]];
                        [touchedCard setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
                        SKAction *dropCard =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
                        [touchedCard runAction:dropCard completion:^{
                            [self.playerCardsList removeObjectAtIndex:i];
                            [self.centerCardPileList addObject:aCard];
                            [self checkWin];
                             self.playsNowIndex=2;
                            if([self.oppenent1CardsList count]==0 && [self.oppenent2CardsList count]==0 && [self.oppenent3CardsList count]==0 && [self.playerCardsList count]==0)
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
                for(int i=0;i<[self.playerCardsList count];i++)
                {
                    Card *aCard=[self.playerCardsList objectAtIndex:i];
                    if([touchedCard.name isEqualToString:aCard.name] && ![aCard isFocused])//card not selected
                    {
                        touchedCard.focused=YES;
                        aCard.focused=YES;
                        [self.playerCardsList replaceObjectAtIndex:i withObject:aCard];
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
                        [self.playerCardsList replaceObjectAtIndex:i withObject:aCard];
                    }
                }
            }
        }
    }
}

-(void) CPUPlays
{
    int cardIndex=0;
    if([self.centerCardPileList count]!=0)
    {
        Card *topCard=[self.centerCardPileList objectAtIndex:[self.centerCardPileList count]-1];
        switch (self.playsNowIndex)
        {
            case 2:
            {
                int foundIndex=0;
                for(Card *aCard in self.oppenent1CardsList)
                {
                    if(aCard.number==topCard.number)
                        cardIndex=foundIndex;
                    else if(aCard.number==11 && cardIndex==0)
                        cardIndex=foundIndex;
                    
                    foundIndex++;
                }
                Card *originalCard= (Card *) [self.oppenent1CardsList objectAtIndex:cardIndex];
                Card *cardToBeDroped = (Card *) [self childNodeWithName:originalCard.name];
                [cardToBeDroped setTexture:[SKTexture textureWithImage:[UIImage imageNamed:[self.imageForCardNameDict objectForKey:cardToBeDroped.name]]]];
                [cardToBeDroped setZPosition:[self.centerCardPileList count]];
                [cardToBeDroped setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
                [self.centerCardPileList addObject:[self.oppenent1CardsList objectAtIndex:cardIndex]];
                [self.oppenent1CardsList removeObjectAtIndex:cardIndex];
                SKAction *CPUDrops =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
                SKAction *CPUDropsWait =[SKAction waitForDuration:0.5];
                SKAction *sequence=[SKAction sequence:@[CPUDrops,CPUDropsWait]];
                [cardToBeDroped runAction:sequence completion:^{
                    [self checkWin];
                    if(self.numOfPlayers==2)
                    {
                        self.playsNowIndex=1;
                        if([self.oppenent1CardsList count]==0 && [self.oppenent2CardsList count]==0 && [self.oppenent3CardsList count]==0 && [self.playerCardsList count]==0)
                            [self checkNewHand];
                    }
                    else
                    {
                        self.playsNowIndex++;
                        if([self.oppenent1CardsList count]==0 && [self.oppenent2CardsList count]==0 && [self.oppenent3CardsList count]==0 && [self.playerCardsList count]==0)
                            [self checkNewHand];
                        else
                            [self CPUPlays];
                    }
                }];
                break;
            }
            case 3:
            {
                int foundIndex=0;
                for(Card *aCard in self.oppenent2CardsList)
                {
                    if(aCard.number==topCard.number)
                        cardIndex=foundIndex;
                    else if(aCard.number==11 && cardIndex==0)
                        cardIndex=foundIndex;
                    
                    foundIndex++;
                }
                
                Card *originalCard= (Card *) [self.oppenent2CardsList objectAtIndex:cardIndex];
                Card *cardToBeDroped = (Card *) [self childNodeWithName:originalCard.name];
                [cardToBeDroped setTexture:[SKTexture textureWithImage:[UIImage imageNamed:[self.imageForCardNameDict objectForKey:cardToBeDroped.name]]]];
                [cardToBeDroped setZPosition:[self.centerCardPileList count]];
                [cardToBeDroped setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
                [self.centerCardPileList addObject:[self.oppenent2CardsList objectAtIndex:cardIndex]];
                [self.oppenent2CardsList removeObjectAtIndex:cardIndex];
                SKAction *CPUDrops =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
                SKAction *CPUDropsWait =[SKAction waitForDuration:0.5];
                SKAction *sequence=[SKAction sequence:@[CPUDrops,CPUDropsWait]];
                [cardToBeDroped runAction:sequence completion:^{
                    [self checkWin];
                    self.playsNowIndex++;
                    if([self.oppenent1CardsList count]==0 && [self.oppenent2CardsList count]==0 && [self.oppenent3CardsList count]==0 && [self.playerCardsList count]==0)
                        [self checkNewHand];
                    else
                        [self CPUPlays];
                }];
                break;
            }
            case 4:
            {
                int foundIndex=0;
                for(Card *aCard in self.oppenent3CardsList)
                {
                    if(aCard.number==topCard.number)
                        cardIndex=foundIndex;
                    else if(aCard.number==11 && cardIndex==0)
                        cardIndex=foundIndex;
                    
                    foundIndex++;
                }
                Card *originalCard= (Card *) [self.oppenent3CardsList objectAtIndex:cardIndex];
                Card *cardToBeDroped = (Card *) [self childNodeWithName:originalCard.name];
                [cardToBeDroped setTexture:[SKTexture textureWithImage:[UIImage imageNamed:[self.imageForCardNameDict objectForKey:cardToBeDroped.name]]]];
                [cardToBeDroped setZPosition:[self.centerCardPileList count]];
                [cardToBeDroped setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
                [self.centerCardPileList addObject:[self.oppenent3CardsList objectAtIndex:cardIndex]];
                [self.oppenent3CardsList removeObjectAtIndex:cardIndex];
                SKAction *CPUDrops =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
                SKAction *CPUDropsWait =[SKAction waitForDuration:0.5];
                SKAction *sequence=[SKAction sequence:@[CPUDrops,CPUDropsWait]];
                [cardToBeDroped runAction:sequence completion:^{
                    [self checkWin];
                    self.playsNowIndex=1;
                    if([self.oppenent1CardsList count]==0 && [self.oppenent2CardsList count]==0 && [self.oppenent3CardsList count]==0 && [self.playerCardsList count]==0)
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
                Card *originalCard= (Card *) [self.oppenent1CardsList objectAtIndex:0];
                Card *cardToBeDroped = (Card *) [self childNodeWithName:originalCard.name];
                [cardToBeDroped setTexture:[SKTexture textureWithImage:[UIImage imageNamed:[self.imageForCardNameDict objectForKey:cardToBeDroped.name]]]];
                [cardToBeDroped setZPosition:[self.centerCardPileList count]];
                [cardToBeDroped setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
                [self.centerCardPileList addObject:[self.oppenent1CardsList objectAtIndex:cardIndex]];
                [self.oppenent1CardsList removeObjectAtIndex:cardIndex];
                SKAction *CPUDrops =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
                SKAction *CPUDropsWait =[SKAction waitForDuration:0.5];
                SKAction *sequence=[SKAction sequence:@[CPUDrops,CPUDropsWait]];
                [cardToBeDroped runAction:sequence completion:^{
                    if(self.numOfPlayers==2)
                    {
                        self.playsNowIndex=1;
                        if([self.oppenent1CardsList count]==0 && [self.oppenent2CardsList count]==0 && [self.oppenent3CardsList count]==0 && [self.playerCardsList count]==0)
                            [self checkNewHand];
                    }
                    else
                    {
                        self.playsNowIndex++;
                        if([self.oppenent1CardsList count]==0 && [self.oppenent2CardsList count]==0 && [self.oppenent3CardsList count]==0 && [self.playerCardsList count]==0)
                            [self checkNewHand];
                        else
                            [self CPUPlays];
                    }
                }];
                break;
            }
            case 3:
            {
                Card *originalCard= (Card *) [self.oppenent2CardsList objectAtIndex:cardIndex];
                Card *cardToBeDroped = (Card *) [self childNodeWithName:originalCard.name];
                [cardToBeDroped setTexture:[SKTexture textureWithImage:[UIImage imageNamed:[self.imageForCardNameDict objectForKey:cardToBeDroped.name]]]];
                [cardToBeDroped setZPosition:[self.centerCardPileList count]];
                [cardToBeDroped setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
                [self.centerCardPileList addObject:[self.oppenent2CardsList objectAtIndex:cardIndex]];
                [self.oppenent2CardsList removeObjectAtIndex:cardIndex];
                SKAction *CPUDrops =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
                SKAction *CPUDropsWait =[SKAction waitForDuration:0.5];
                SKAction *sequence=[SKAction sequence:@[CPUDrops,CPUDropsWait]];
                [cardToBeDroped runAction:sequence completion:^{
                    self.playsNowIndex++;
                    if([self.oppenent1CardsList count]==0 && [self.oppenent2CardsList count]==0 && [self.oppenent3CardsList count]==0 && [self.playerCardsList count]==0)
                        [self checkNewHand];
                    else
                        [self CPUPlays];
                }];
                break;
            }
            case 4:
            {
                Card *originalCard= (Card *) [self.oppenent3CardsList objectAtIndex:cardIndex];
                Card *cardToBeDroped = (Card *) [self childNodeWithName:originalCard.name];
                [cardToBeDroped setTexture:[SKTexture textureWithImage:[UIImage imageNamed:[self.imageForCardNameDict objectForKey:cardToBeDroped.name]]]];
                [cardToBeDroped setZPosition:[self.centerCardPileList count]];
                [cardToBeDroped setZRotation:((((float)rand() / RAND_MAX) * 100)/100)*M_PI];
                [self.centerCardPileList addObject:[self.oppenent3CardsList objectAtIndex:cardIndex]];
                [self.oppenent3CardsList removeObjectAtIndex:cardIndex];
                SKAction *CPUDrops =[SKAction moveTo:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)  duration:0.2];
                SKAction *CPUDropsWait =[SKAction waitForDuration:0.5];
                SKAction *sequence=[SKAction sequence:@[CPUDrops,CPUDropsWait]];
                [cardToBeDroped runAction:sequence];
                self.playsNowIndex=1;
                if([self.oppenent1CardsList count]==0 && [self.oppenent2CardsList count]==0 && [self.oppenent3CardsList count]==0 && [self.playerCardsList count]==0)
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
    if([self.centerCardPileList count]<2)
        return;
    
    Card *topCard=(Card *)[self.centerCardPileList objectAtIndex:[self.centerCardPileList count]-1];
    Card *secondTopCard=(Card *)[self.centerCardPileList objectAtIndex:[self.centerCardPileList count]-2];
    
    if(topCard.number==11 || topCard.number==secondTopCard.number)//wins hand
    {
        NSLog(@"win %d vs %d",topCard.number,secondTopCard.number);
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
        
        while ([self.centerCardPileList count]!=0)
        {
            Card *aCard=(Card *)[self.centerCardPileList objectAtIndex:0];
            [[self childNodeWithName:aCard.name] runAction:moveToPlayer];
            if(self.playsNowIndex==1)//player wins hand
                [self.playerGatheredCardsList addObject:[self.centerCardPileList objectAtIndex:0]];
            else if(self.playsNowIndex==2)
                [self.oppenent1GatheredCardsList addObject:[self.centerCardPileList objectAtIndex:0]];
            else if(self.playsNowIndex==3)
                [self.oppenent2GatheredCardsList addObject:[self.centerCardPileList objectAtIndex:0]];
            else
                [self.oppenent3GatheredCardsList addObject:[self.centerCardPileList objectAtIndex:0]];
            [self.centerCardPileList removeObjectAtIndex:0];
        }
    }
    
}

-(void) buildDeck
{
    self.deck=[[NSMutableArray alloc] init];
    for(int i=0;i<52;i++)
    {
        //spades
        if(i/13==0)
        {
            Card *newCard=[Card spriteNodeWithImageNamed:[NSString stringWithFormat:@"s%d.png",i+1]];
            if(i==11 || i==1)
                newCard.pointsWorth=1;
            else
                newCard.pointsWorth=0;
            newCard.focused=NO;
            newCard.number=i+1;
            [newCard setName:[NSString stringWithFormat:@"card%d",i]];
            [self.imageForCardNameDict setValue:[NSString stringWithFormat:@"s%d.png",i+1] forKey:[NSString stringWithFormat:@"card%d",i]];
            [self.deck addObject:newCard];
            NSLog(@"created : %d of spades",newCard.number);
        }
        //hearts
        else if(i/13==1)
        {
            Card *newCard=[Card spriteNodeWithImageNamed:[NSString stringWithFormat:@"h%d.png",i%13+1]];
            if(i%13==11 || i%13==1)
                newCard.pointsWorth=1;
            else
                newCard.pointsWorth=0;
            newCard.focused=NO;
            newCard.number=i%13+1;
            [newCard setName:[NSString stringWithFormat:@"card%d",i]];
            [self.imageForCardNameDict setValue:[NSString stringWithFormat:@"h%d.png",i%13+1] forKey:[NSString stringWithFormat:@"card%d",i]];
            [self.deck addObject:newCard];
             NSLog(@"created : %d of hearts",newCard.number);
        }
        //clubs
        else if(i/13==2)
        {
            Card *newCard=[Card spriteNodeWithImageNamed:[NSString stringWithFormat:@"c%d.png",i%13+1]];
            if(i%13==11 || i%13==1)
                newCard.pointsWorth=1;
            else if(i%13==2)
                newCard.pointsWorth=2;
            else
                newCard.pointsWorth=0;
            newCard.focused=NO;
            newCard.number=i%13+1;
            [newCard setName:[NSString stringWithFormat:@"card%d",i]];
            [self.imageForCardNameDict setValue:[NSString stringWithFormat:@"c%d.png",i%13+1] forKey:[NSString stringWithFormat:@"card%d",i]];
            [self.deck addObject:newCard];
             NSLog(@"created : %d of clubs",newCard.number);
        }
        //diamonds
        else
        {
            Card *newCard=[Card spriteNodeWithImageNamed:[NSString stringWithFormat:@"d%d.png",i%13+1]];
            if(i%13==11 || i%13==1)
                newCard.pointsWorth=1;
            else if(i%13==10)
                newCard.pointsWorth=3;
            else
                newCard.pointsWorth=0;
            newCard.focused=NO;
            newCard.number=i%13+1;
            [newCard setName:[NSString stringWithFormat:@"card%d",i]];
            [self.imageForCardNameDict setValue:[NSString stringWithFormat:@"d%d.png",i%13+1] forKey:[NSString stringWithFormat:@"card%d",i]];
            [self.deck addObject:newCard];
             NSLog(@"created : %d of diamonds",newCard.number);
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
                Card *newCard= [self.deck objectAtIndex:0];
                [newCard setPosition:deck.position];
                [newCard setFocused:NO];
                [newCard setZPosition:(CGFloat)[self.playerCardsList count]];
                [newCard setScale:0.8];
                //[newCard setLightingBitMask:1];
                [self addChild:newCard];
                [self.playerCardsList addObject:newCard];
                [self.deck removeObjectAtIndex:0];
                SKAction *moveAction = [SKAction moveTo:CGPointMake(self.view.frame.size.width/5+[self.playerCardsList count]*35, 0) duration:0.2];
                [newCard runAction:moveAction];
                self.playsNowIndex++;
                break;
            }
            case 2:
            {
                Card *newCard= (Card *)[self.deck objectAtIndex:0];
                [newCard setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"b1fv.png"]]];
                [newCard setPosition:deck.position];
                [newCard setScale:0.8];
                //[newCard setLightingBitMask:1];
                [self addChild:newCard];
                [newCard setZPosition:(CGFloat)[self.oppenent1CardsList count]];
                [newCard setFocused:NO];
                [self.oppenent1CardsList addObject:[self.deck objectAtIndex:0]];
                [self.deck removeObjectAtIndex:0];
                SKAction *moveAction2 = [SKAction moveTo:CGPointMake(self.view.frame.size.width/5+[self.oppenent1CardsList count]*35, self.view.frame.size.height) duration:0.2];
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
        Card *centerCard=[self.deck objectAtIndex:0];
        SKSpriteNode *deck =(SKSpriteNode *) [self childNodeWithName:@"deckCard"];
        [centerCard setPosition:deck.position];
        [centerCard setFocused:NO];
        [centerCard setScale:0.8];
        //[centerCard setLightingBitMask:1];
        [self addChild:centerCard];
        [self.centerCardPileList addObject:[self.deck objectAtIndex:0]];
        [self.deck removeObjectAtIndex:0];
        [centerCard setZPosition:[self.centerCardPileList count]];
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
    if([self.deck count]==0)
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
                Card *newCard= [self.deck objectAtIndex:0];
                [newCard setPosition:deck.position];
                [newCard setFocused:NO];
                [newCard setZPosition:(CGFloat)[self.playerCardsList count]];
                [newCard setScale:0.8];
                //[newCard setLightingBitMask:1];
                [self addChild:newCard];
                [self.playerCardsList addObject:newCard];
                [self.deck removeObjectAtIndex:0];
                SKAction *moveAction = [SKAction moveTo:CGPointMake(self.view.frame.size.width/4+[self.playerCardsList count]*35, newCard.frame.size.height/2) duration:0.2];
                [newCard runAction:moveAction];
                self.playsNowIndex++;
                break;
            }
            case 2://left
            {
                Card *newCard= (Card *)[self.deck objectAtIndex:0];
                [newCard setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"b1fv.png"]]];
                [newCard setPosition:deck.position];
                [newCard setScale:0.8];
                //[newCard setLightingBitMask:1];
                [self addChild:newCard];
                [newCard setZPosition:(CGFloat)[self.oppenent1CardsList count]];
                [newCard setZRotation:M_PI/2];
                [newCard setFocused:NO];
                [self.oppenent1CardsList addObject:[self.deck objectAtIndex:0]];
                [self.deck removeObjectAtIndex:0];
                SKAction *moveAction2 = [SKAction moveTo:CGPointMake(self.view.frame.size.width/12, (self.view.frame.size.height)/5+[self.oppenent1CardsList count]*20) duration:0.2];
                [newCard runAction:moveAction2];
                self.playsNowIndex++;
                break;
            }
            case 3://up
            {
                Card *newCard= (Card *)[self.deck objectAtIndex:0];
                [newCard setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"b1fv.png"]]];
                [newCard setPosition:deck.position];
                [newCard setScale:0.8];
                //[newCard setLightingBitMask:1];
                [self addChild:newCard];
                [newCard setZPosition:(CGFloat)[self.oppenent2CardsList count]];
                [newCard setFocused:NO];
                [self.oppenent2CardsList addObject:[self.deck objectAtIndex:0]];
                [self.deck removeObjectAtIndex:0];
                SKAction *moveAction = [SKAction moveTo:CGPointMake(self.view.frame.size.width/3.5+[self.oppenent2CardsList count]*20, (6.5*self.view.frame.size.height)/8) duration:0.2];
                [newCard runAction:moveAction];
                self.playsNowIndex++;
                break;
            }
            case 4://right
            {
                Card *newCard= (Card *)[self.deck objectAtIndex:0];
                [newCard setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"b1fv.png"]]];
                [newCard setPosition:deck.position];
                [newCard setZRotation:M_PI/2];
                [newCard setScale:0.8];
                //[newCard setLightingBitMask:1];
                [self addChild:newCard];
                [newCard setZPosition:(CGFloat)[self.oppenent3CardsList count]];
                [newCard setFocused:NO];
                [self.oppenent3CardsList addObject:[self.deck objectAtIndex:0]];
                [self.deck removeObjectAtIndex:0];
                SKAction *moveAction = [SKAction moveTo:CGPointMake((7*self.view.frame.size.width)/8, (6*self.view.frame.size.height)/8-[self.oppenent3CardsList count]*20) duration:0.2];
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
        Card *centerCard=[self.deck objectAtIndex:0];
        SKSpriteNode *deck =(SKSpriteNode *) [self childNodeWithName:@"deckCard"];
        [centerCard setPosition:deck.position];
        [centerCard setFocused:NO];
        [centerCard setScale:0.8];
        //[centerCard setLightingBitMask:1];
        [self addChild:centerCard];
        [self.centerCardPileList addObject:[self.deck objectAtIndex:0]];
        [self.deck removeObjectAtIndex:0];
        [centerCard setZPosition:[self.centerCardPileList count]];
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
    if([self.deck count]==0)
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
    if([self.deck count]!=0)
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
