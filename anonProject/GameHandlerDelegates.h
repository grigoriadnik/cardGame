//
//  GameHandlerDelegates.h
//  anonProject
//
//  Created by Nikos Grigoriadis on 6/22/17.
//  Copyright © 2017 anon. All rights reserved.
//

#ifndef GameHandlerDelegates_h
#define GameHandlerDelegates_h

typedef NS_ENUM(NSInteger, GameMode) {
    TwoPlayerMode,
    FourPlayerMode
};

@protocol GameHandlerDelegate

-(void) dealToPlayer1 : (GameMode) aGameMode dealtCard : (Card *) dealtCard numOfCards : (NSInteger) numOfCards;
-(void) dealToPlayer2 : (GameMode) aGameMode dealtCard : (Card *) dealtCard numOfCards : (NSInteger) numOfCards;
-(void) dealToPlayer3 : (GameMode) aGameMode dealtCard : (Card *) dealtCard numOfCards : (NSInteger) numOfCards;
-(void) dealToPlayer4 : (GameMode) aGameMode dealtCard : (Card *) dealtCard numOfCards : (NSInteger) numOfCards;
-(void) dealMiddle    : (GameMode) aGameMode dealtCard : (Card *) dealtCard;
-(void) removeLastCardOnDeck;

-(void) player1GathersCards : (GameMode) aGameMode;
-(void) player2GathersCards : (GameMode) aGameMode;
-(void) player3GathersCards : (GameMode) aGameMode;
-(void) player4GathersCards : (GameMode) aGameMode;
-(void) CPUPlays;

@end

#endif /* GameHandlerDelegates_h */
