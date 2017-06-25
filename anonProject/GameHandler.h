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

+(GameHandler *) initGameWithNumberOfPlayers : (NSInteger) numOfPlayers gameDeck : (Deck *) gameDeck listener : (SKScene<GameHandlerDelegate>*) listener;
-(Card *) CPUPlayWithDeck : (Deck *) gameDeck;
-(BOOL) checkIfAnyPlayerHasCardsOnHand;
-(void) addCardFromPileToPlayer : (Card *) aCard;
-(Player *) getUser;
-(void) checkWinWithDeck : (Deck *) gameDeck;
-(void) endTurn : (Deck *) gameDeck;

@end
