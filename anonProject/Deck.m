//
//  Deck.m
//  anonProject
//
//  Created by Nikos Grigoriadis on 6/21/17.
//  Copyright © 2017 anon. All rights reserved.
//

#import "Deck.h"

@implementation Deck

+(Deck *) initDeck
{
    Deck *newDeck = [[Deck alloc] init];
    newDeck.cards = [[NSMutableArray alloc] init];
    
    for(int i=0;i<52;i++)
    {
        //spades
        if(i/13==0)
        {
            Card *newCard=[Card spriteNodeWithImageNamed:[NSString stringWithFormat:@"s%d.png",i+1]];
            [newCard initCardWithNumber:i+1 powerType:((i/13==1)?2:1) pointsWorth:((i==11 || i==1)?1:0) cardImageString:[NSString stringWithFormat:@"s%d.png",i+1] isFocused:NO cardIdentifier:i];
            [newDeck.cards addObject:newCard];
        }
        //hearts
        else if(i/13==1)
        {
            Card *newCard=[Card spriteNodeWithImageNamed:[NSString stringWithFormat:@"h%d.png",i%13+1]];
            [newCard initCardWithNumber:i+1 powerType:((i/13==1)?2:1) pointsWorth:((i%13==11 || i%13==1)?1:0) cardImageString:[NSString stringWithFormat:@"h%d.png",i%13+1] isFocused:NO cardIdentifier:i];
            [newDeck.cards addObject:newCard];
        }
        //clubs
        else if(i/13==2)
        {
            Card *newCard=[Card spriteNodeWithImageNamed:[NSString stringWithFormat:@"c%d.png",i%13+1]];
            [newCard initCardWithNumber:i+1 powerType:((i/13==1)?2:1) pointsWorth:((i%13==11 || i%13==1)?1:0) cardImageString:[NSString stringWithFormat:@"c%d.png",i%13+1] isFocused:NO cardIdentifier:i];
            [newDeck.cards addObject:newCard];
        }
        //diamonds
        else
        {
            Card *newCard=[Card spriteNodeWithImageNamed:[NSString stringWithFormat:@"d%d.png",i%13+1]];
            [newCard initCardWithNumber:i+1 powerType:((i/13==1)?2:1) pointsWorth:((i%13==11 || i%13==1)?1:0) cardImageString:[NSString stringWithFormat:@"d%d.png",i%13+1] isFocused:NO cardIdentifier:i];
            [newDeck.cards addObject:newCard];
        }
    }
    return newDeck;
}

-(Card *) getTopCard
{
    Card *aCard = [self.cards objectAtIndex:0];
    [self.cards removeObjectAtIndex:0];
    return aCard;
}

-(NSInteger) getDeckCount
{
    return [self.cards count];
}

-(void) addToCenterCardPileCard : (Card *) aCard
{
    [self.centerCardPileList addObject:aCard];
}

-(NSInteger) getCenterCardPileCount
{
    return [self.centerCardPileList count];
}

-(Card *) getCenterCardPileTopCard
{
    return [self.centerCardPileList objectAtIndex:[self getCenterCardPileCount]-1];
}

-(Card *) getCenterCardPileSecondTopCard
{
    return [self.centerCardPileList objectAtIndex:[self getCenterCardPileCount]-2];
}

-(Card *) getCenterCardPileBottomCard
{
    return [self.centerCardPileList objectAtIndex:0];
}

-(void) removeCenterCardPileBottomCard
{
    [self.centerCardPileList removeObjectAtIndex:0];
}

@end
