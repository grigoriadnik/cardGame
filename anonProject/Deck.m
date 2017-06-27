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
    newDeck.centerCardPileList = [[NSMutableArray alloc] init];
    NSInteger pointsWorth;
    NSInteger cardTextureIdentifier = 0;
    for(NSInteger i=0;i<52;i++)
    {
        cardTextureIdentifier = i%13 + 1;
        //spades
        if(i/13==0)
        {
            Card *newCard=[Card spriteNodeWithImageNamed:[NSString stringWithFormat:@"s%ld.png",cardTextureIdentifier]];
            pointsWorth = ((i==10 || i==0)?1:0);
            [newCard initCardWithNumber:i powerType:((i/13==1)?2:1) pointsWorth:pointsWorth cardImageString:[NSString stringWithFormat:@"s%ld.png",(long)cardTextureIdentifier] isFocused:NO cardIdentifier:i];
            [newDeck.cards addObject:newCard];
        }
        //hearts
        else if(i/13==1)
        {
            Card *newCard=[Card spriteNodeWithImageNamed:[NSString stringWithFormat:@"h%ld.png",cardTextureIdentifier]];
            pointsWorth = ((i%13==10 || i%13==0)?1:0);
            [newCard initCardWithNumber:i%13 powerType:((i/13==1)?2:1) pointsWorth:pointsWorth cardImageString:[NSString stringWithFormat:@"h%ld.png",cardTextureIdentifier] isFocused:NO cardIdentifier:i];
            [newDeck.cards addObject:newCard];
        }
        //clubs
        else if(i/13==2)
        {
            Card *newCard=[Card spriteNodeWithImageNamed:[NSString stringWithFormat:@"c%ld.png",cardTextureIdentifier]];
            pointsWorth = ((i%13==10 || i%13==0)?1:0);
            pointsWorth = ((i%13==1)?2:pointsWorth);
            [newCard initCardWithNumber:i%13 powerType:((i/13==1)?2:1) pointsWorth:pointsWorth cardImageString:[NSString stringWithFormat:@"c%ld.png",cardTextureIdentifier] isFocused:NO cardIdentifier:i];
            [newDeck.cards addObject:newCard];
        }
        //diamonds
        else
        {
            Card *newCard=[Card spriteNodeWithImageNamed:[NSString stringWithFormat:@"d%ld.png",cardTextureIdentifier]];
            pointsWorth = ((i%13==10 || i%13==0)?1:0);
            pointsWorth = ((i%13==9)?3:pointsWorth);
            [newCard initCardWithNumber:i%13 powerType:((i/13==1)?2:1) pointsWorth:pointsWorth cardImageString:[NSString stringWithFormat:@"d%ld.png",cardTextureIdentifier] isFocused:NO cardIdentifier:i];
            [newDeck.cards addObject:newCard];
        }
    }
    
    [newDeck shuffleDeck];
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

-(void) shuffleDeck
{
    for (NSInteger i = 0 ; i < [self.cards count] ; i++) {
        
        NSInteger newPositionIndex = [Utils getRandomNumberBetween:0 to:[self.cards count] -1 ];
        id temp = [self.cards objectAtIndex:i];
        [self.cards replaceObjectAtIndex:i withObject:[self.cards objectAtIndex:newPositionIndex]];
        [self.cards replaceObjectAtIndex:newPositionIndex withObject:temp];
    }
}

@end
