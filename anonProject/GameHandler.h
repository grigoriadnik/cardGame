//
//  GameHandler.h
//  anonProject
//
//  Created by Nikos Grigoriadis on 6/22/17.
//  Copyright © 2017 anon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"
#import "Deck.h"
#import "GameHandlerDelegates.h"

@interface GameHandler : NSObject

@property NSMutableArray *players;
@property NSInteger currentPlayerIndex;
@property GameMode gameMode;
@property (nonatomic, weak) id<GameHandlerDelegate> gameHandlerDelegate;
@property NSTimer *dealer;
@property BOOL gameStart;
@property NSInteger teamAPoints;
@property NSInteger teamBPoints;
@property Deck *gameDeck;

+(GameHandler *) initGameWithNumberOfPlayers : (NSInteger) numOfPlayers listener : (SKScene<GameHandlerDelegate>*) listener;
-(Card *) CPUPlay;
-(BOOL) checkIfAnyPlayerHasCardsOnHand;
-(void) addCardFromPileToPlayer : (Card *) aCard;
-(Player *) getUser;
-(void) checkWin;
-(void) endTurn;
-(void) countPoints;
-(void) addToCenterCardPile : (Card *) card;
-(NSInteger) getCenterCardPileCount;
-(void) removeCenterCardPileBottomCard;
-(Card *) getCenterCardPileBottomCard;

@end
