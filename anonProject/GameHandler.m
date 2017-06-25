//
//  GameHandler.m
//  anonProject
//
//  Created by Nikos Grigoriadis on 6/22/17.
//  Copyright © 2017 anon. All rights reserved.
//

#import "GameHandler.h"

#define NumberOfCardsFullHand 6
#define NumberOfCardsCentePile 4

@implementation GameHandler

#pragma mark -
#pragma mark Constructor

+(GameHandler *) initGameWithNumberOfPlayers : (NSInteger) numOfPlayers gameDeck : (Deck *) gameDeck listener : (UIViewController<GameHandlerDelegate>*) listener
{
    GameHandler *newGameHandler = [GameHandler alloc];
    newGameHandler.players = [[NSMutableArray alloc] init];
    newGameHandler.currentPlayerIndex = 0;
    newGameHandler.gameMode = (numOfPlayers == 4) ? FourPlayerMode : TwoPlayerMode;
    newGameHandler.gameHandlerDelegate = listener;
    
    for(int i = 0 ; i < numOfPlayers ; i++) {
        [newGameHandler.players addObject:[Player initPlayerisCpu:((i == 0) ? NO : YES) withIndex:i isUser:((i == 0) ? YES : NO)]];
    }
    
    newGameHandler.gameStart = YES;
    newGameHandler.dealer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:newGameHandler selector:@selector(dealCardsWithDeck:) userInfo:gameDeck repeats:YES];
    return newGameHandler;
}

#pragma mark -
#pragma mark CPU Play Logic

-(Card *) CPUPlayWithDeck : (Deck *) gameDeck
{
    Player *curPlayer = [self.players objectAtIndex:self.currentPlayerIndex%[self numOfPlayers]];
    if(![curPlayer isCPU])
        return nil;
    
    NSInteger cardIndex=0;
    Card *returnedCard;
    if([gameDeck getCenterCardPileCount] != 0) {
        
        Card *topCard=[gameDeck getCenterCardPileTopCard];
        cardIndex = [curPlayer getIndexForCardNumber:topCard.number];
        returnedCard = [curPlayer getPlayerCardAtIndex:cardIndex];
        [gameDeck addToCenterCardPileCard:[curPlayer getPlayerCardAtIndex:cardIndex]];
        [curPlayer removePlayerCardAtIndex:cardIndex];
        
    } else {
        
        returnedCard= [curPlayer getPlayerCardAtIndex:cardIndex];
        [gameDeck addToCenterCardPileCard:[curPlayer getPlayerCardAtIndex:cardIndex]];
        [curPlayer removePlayerCardAtIndex:cardIndex];
        
    }
    return returnedCard;
}

#pragma mark -
#pragma mark Deal Cards Logic

-(void) dealCardsWithDeck : (NSTimer *) aTimer
{
    Deck *gameDeck =  [aTimer userInfo];
    if(self.gameHandlerDelegate !=nil) {
        if(![self allPlayersHaveFullHand]) {
            
            Player *curPlayer = [self.players objectAtIndex:self.currentPlayerIndex%[self numOfPlayers]];
            Card *newCard= [gameDeck getTopCard];
            [curPlayer addToPlayerCards:newCard];
            
            switch (curPlayer.playerIndex % [self numOfPlayers]) {
                case 0:
                    [self.gameHandlerDelegate dealToPlayer1:self.gameMode dealtCard:newCard numOfCards:[curPlayer getPlayerCardListCount]];
                    break;
                case 1:
                    [self.gameHandlerDelegate dealToPlayer2:self.gameMode dealtCard:newCard numOfCards:[curPlayer getPlayerCardListCount]];
                    break;
                case 2:
                    [self.gameHandlerDelegate dealToPlayer3:self.gameMode dealtCard:newCard numOfCards:[curPlayer getPlayerCardListCount]];
                    break;
                case 3:
                    [self.gameHandlerDelegate dealToPlayer4:self.gameMode dealtCard:newCard numOfCards:[curPlayer getPlayerCardListCount]];
                    break;
                    
                default:
                    break;
            }
            
            if([gameDeck getDeckCount] == 0) {
                [self.gameHandlerDelegate removeLastCardOnDeck];
            }
            self.currentPlayerIndex++;
            
        } else if([self centerPileIsDealtWithDeck:gameDeck] && self.gameStart) {
            
            Card *newCard= [gameDeck getTopCard];
            [gameDeck addToCenterCardPileCard:newCard];
            [self.gameHandlerDelegate dealMiddle:self.gameMode dealtCard:newCard];
            
        } else {
            
            [self.dealer invalidate];
            self.gameStart = NO;
            
        }
    }
}

-(void) checkWinWithDeck : (Deck *) gameDeck
{
    if([gameDeck getCenterCardPileCount] < 2) {
         return;
    }
    
    if(self.gameHandlerDelegate == nil) {
        return;
    }
    
    Card *topCard = [gameDeck getCenterCardPileTopCard];
    Card *secondTopCard = [gameDeck getCenterCardPileSecondTopCard];
    
    if(topCard.number==11 || topCard.number==secondTopCard.number)//wins hand
    {
        switch (self.currentPlayerIndex % [self numOfPlayers]) {
            case 0:
                [self.gameHandlerDelegate player1GathersCards:self.gameMode];
                break;
            case 1:
                [self.gameHandlerDelegate player2GathersCards:self.gameMode];
                break;
            case 2:
                [self.gameHandlerDelegate player3GathersCards:self.gameMode];
                break;
            case 3:
                [self.gameHandlerDelegate player4GathersCards:self.gameMode];
                break;
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark Util Functions

-(BOOL) centerPileIsDealtWithDeck : (Deck *) gameDeck
{
    return [gameDeck getCenterCardPileCount] < 4;
}

-(BOOL) allPlayersHaveFullHand
{
    for (Player *aPlayer in self.players) {
        if([aPlayer getPlayerCardListCount] < NumberOfCardsFullHand) {
            return NO;
        }
    }
    
    return YES;
}

-(Player *) getUser
{
    for (Player *aPlayer in self.players) {
        if(aPlayer.isUser)
            return aPlayer;
    }
    return nil;
}

-(BOOL) checkIfAnyPlayerHasCardsOnHand
{
    for (Player *aPlayer in self.players) {
        if([aPlayer getPlayerCardListCount] > 0){
            return YES;
        }
    }
    return NO;
}

-(void) newRoundOrEndGameWithDeck : (Deck *) gameDeck
{
    if([gameDeck getDeckCount] == 0) {
        NSLog(@"end game :)");
    } else {
        self.dealer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(dealCardsWithDeck:) userInfo:gameDeck repeats:YES];
    }
}

-(NSInteger) numOfPlayers
{
    return [self.players count];
}

-(void) addCardFromPileToPlayer : (Card *) aCard
{
    Player *curPlayer = [self.players objectAtIndex:self.currentPlayerIndex%[self numOfPlayers]];
    [curPlayer addToPlayerGatheredCards:aCard];
}

-(void) endTurn : (Deck *) gameDeck
{
    self.currentPlayerIndex++;
    if(![self checkIfAnyPlayerHasCardsOnHand]) {
        [self newRoundOrEndGameWithDeck:gameDeck];
    } else {
        Player *aPlayer = [self.players objectAtIndex:self.currentPlayerIndex % [self numOfPlayers]];
        if(aPlayer.isCPU && self.gameHandlerDelegate!=nil) {
            [self.gameHandlerDelegate CPUPlays];
        }
    }
}

@end
