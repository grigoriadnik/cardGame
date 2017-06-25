//
//  Deck.h
//  anonProject
//
//  Created by Nikos Grigoriadis on 6/21/17.
//  Copyright © 2017 anon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "Utils.h"

@interface Deck : NSObject

@property NSMutableArray *cards;
@property NSMutableArray *centerCardPileList;

+(Deck *) initDeck;
-(Card *) getTopCard;
-(NSInteger) getDeckCount;

-(void) addToCenterCardPileCard : (Card *) aCard;
-(NSInteger) getCenterCardPileCount;
-(Card *) getCenterCardPileTopCard;
-(Card *) getCenterCardPileSecondTopCard;
-(Card *) getCenterCardPileBottomCard;
-(void) removeCenterCardPileBottomCard;

@end
