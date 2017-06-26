//
//  Player.m
//  anonProject
//
//  Created by Nikos Grigoriadis on 6/21/17.
//  Copyright © 2017 anon. All rights reserved.
//

#import "Player.h"

@implementation Player

+(Player *) initPlayerisCpu : (BOOL) isCPU withIndex : (NSInteger) index isUser : (BOOL) isUser team : (PlayerTeam) team
{
    Player *newPlayer = [[Player alloc] init];
    newPlayer.playerCardList = [[NSMutableArray alloc] init];
    newPlayer.playerGatheredCardList = [[NSMutableArray alloc] init];
    newPlayer.isCPU = isCPU;
    newPlayer.playerIndex = index;
    newPlayer.isUser = isUser;
    newPlayer.team = team;
    
    return newPlayer;
}

-(NSInteger) getPlayerCardListCount
{
    return [self.playerCardList count];
}

-(NSInteger) getPlayerGatheredCardListCount
{
    return [self.playerGatheredCardList count];
}

-(Card *) getPlayerCardAtIndex : (NSInteger)index
{
    return [self.playerCardList objectAtIndex:index];
}

-(Card *) getPlayerGatheredCardAtIndex : (NSInteger) index
{
    return [self.playerGatheredCardList objectAtIndex:index];
}

-(void) removePlayerCardAtIndex : (NSInteger) index
{
    [self.playerCardList removeObjectAtIndex:index];
}

-(NSInteger) getIndexForCardNumber : (NSInteger) cardNumber
{
    NSInteger foundIndex=0;
    NSInteger cardIndex=0;
    for(Card *aCard in self.playerCardList)
    {
        if(aCard.number == cardNumber)
            cardIndex=foundIndex;
        else if(aCard.number == 11 && cardIndex == 0)
            cardIndex=foundIndex;
        
        foundIndex++;
    }
    
    return cardIndex;
}

-(void) addToPlayerGatheredCards : (Card *) aCard
{
    [self.playerGatheredCardList addObject:aCard];
}

-(void) addToPlayerCards : (Card *) aCard
{
    [self.playerCardList addObject:aCard];
}

-(void) preparePlayerForNewRound
{
    self.playerGatheredCardList = [[NSMutableArray alloc] init];
    self.playerCardList = [[NSMutableArray alloc] init];
}

@end
