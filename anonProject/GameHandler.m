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
#define PointsToEndGame 255

@implementation GameHandler

#pragma mark -
#pragma mark Constructor

+(GameHandler *) initGameWithNumberOfPlayers : (NSInteger) numOfPlayers listener : (SKScene<GameHandlerDelegate>*) listener
{
    GameHandler *newGameHandler = [GameHandler alloc];
    newGameHandler.players = [[NSMutableArray alloc] init];
    newGameHandler.currentPlayerIndex = 0;
    newGameHandler.gameMode = (numOfPlayers == 4) ? FourPlayerMode : TwoPlayerMode;
    newGameHandler.gameHandlerDelegate = listener;
    newGameHandler.teamAPoints = 0;
    newGameHandler.teamBPoints = 0;
    newGameHandler.gameDeck = [Deck initDeck];
    
    for(int i = 0 ; i < numOfPlayers ; i++) {
        [newGameHandler.players addObject:[Player initPlayerisCpu:((i == 0) ? NO : YES) withIndex:i isUser:((i == 0) ? YES : NO) team:((i == 0 || i==2) ? TeamA : TeamB)]];
    }
    
    newGameHandler.gameStart = YES;
    newGameHandler.dealer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:newGameHandler selector:@selector(dealCardsWithDeck:) userInfo:newGameHandler.gameDeck repeats:YES];
    return newGameHandler;
}

#pragma mark -
#pragma mark CPU Play Logic

-(Card *) CPUPlay
{
    Player *curPlayer = [self.players objectAtIndex:self.currentPlayerIndex%[self numOfPlayers]];
    if(![curPlayer isCPU])
        return nil;
    
    NSInteger cardIndex=0;
    Card *returnedCard;
    if([self.gameDeck getCenterCardPileCount] != 0) {
        
        Card *topCard=[self.gameDeck getCenterCardPileTopCard];
        cardIndex = [curPlayer getIndexForCardNumber:topCard.number];
        returnedCard = [curPlayer getPlayerCardAtIndex:cardIndex];
        [self.gameDeck addToCenterCardPileCard:[curPlayer getPlayerCardAtIndex:cardIndex]];
        [curPlayer removePlayerCardAtIndex:cardIndex];
        
    } else {
        
        returnedCard= [curPlayer getPlayerCardAtIndex:cardIndex];
        [self.gameDeck addToCenterCardPileCard:[curPlayer getPlayerCardAtIndex:cardIndex]];
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
            
        } else if([self centerPileIsDealt] && self.gameStart) {
            
            Card *newCard= [gameDeck getTopCard];
            [gameDeck addToCenterCardPileCard:newCard];
            [self.gameHandlerDelegate dealMiddle:self.gameMode dealtCard:newCard];
            
        } else {
            
            [self.dealer invalidate];
            self.gameStart = NO;
            
        }
    }
}

-(void) checkWin
{
    if([self getCenterCardPileCount] < 2) {
         return;
    }
    
    if(self.gameHandlerDelegate == nil) {
        return;
    }
    
    Card *topCard = [self.gameDeck getCenterCardPileTopCard];
    Card *secondTopCard = [self.gameDeck getCenterCardPileSecondTopCard];
    
    if(topCard.number==11 || topCard.number==secondTopCard.number)//wins hand
    {
        if([self.gameDeck getCenterCardPileCount] == 2){//kseri
            Player *aPlayer = [self.players objectAtIndex:self.currentPlayerIndex % [self numOfPlayers]];
            if(topCard.number == 1) {
                aPlayer.kseres +=2;
            } else {
                aPlayer.kseres++;
            }
        }
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

-(BOOL) centerPileIsDealt
{
    return [self.gameDeck getCenterCardPileCount] < 4;
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

-(void) newRoundOrEndGameWithDeck
{
    if([self.gameDeck getDeckCount] == 0) {
        
        [self.gameHandlerDelegate prepareUIForNewRound];
        [self countPoints];
        [self startNewRound];
        [self.gameHandlerDelegate setTeamAScore:self.teamAPoints teamBScore:self.teamBPoints];
        
    } else {
        self.dealer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(dealCardsWithDeck:) userInfo:self.gameDeck repeats:YES];
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

-(void) endTurn
{
    self.currentPlayerIndex++;
    if(![self checkIfAnyPlayerHasCardsOnHand]) {
        [self newRoundOrEndGameWithDeck];
    } else {
        Player *aPlayer = [self.players objectAtIndex:self.currentPlayerIndex % [self numOfPlayers]];
        if(aPlayer.isCPU && self.gameHandlerDelegate!=nil) {
            [self.gameHandlerDelegate CPUPlays];
        }
    }
}

-(void) countPoints
{
    NSInteger pointsCount = 0;
    NSInteger teamAtotalCards = 0;
    NSInteger teamBtotalCards = 0;
    for (Player *aPlayer in self.players) {
        pointsCount = 0;
        pointsCount = 10 * aPlayer.kseres;
        for (Card *aCard in aPlayer.playerGatheredCardList) {
            pointsCount += aCard.pointsWorth;
        }
        if(aPlayer.team == TeamA) {
            teamAtotalCards += [aPlayer getPlayerGatheredCardListCount];
            self.teamAPoints += pointsCount;
        } else {
            teamBtotalCards += [aPlayer getPlayerGatheredCardListCount];
            self.teamBPoints += pointsCount;
        }
    }
    
    if(teamAtotalCards > teamBtotalCards) {
        self.teamAPoints += 3;
    } else if(teamAtotalCards < teamBtotalCards){
        self.teamBPoints += 3;
    }
    
    //double the points
    if(teamAtotalCards == 0) {
        self.teamBPoints = self.teamBPoints * 2;
    } else if(teamBtotalCards == 0) {
        self.teamAPoints = self.teamAPoints * 2;
    }
}

-(PlayerTeam) whichTeamWonTheGame
{
    if(self.teamAPoints > 255 && self.teamBPoints > 255) {
        if(self.teamAPoints == self.teamBPoints) {
            return NoTeam;
        } else {
            return ((self.teamAPoints > self.teamBPoints) ? TeamA : TeamB);
        }
    } else if (self.teamAPoints > 255) {
        return TeamA;
    } else if(self.teamBPoints > 255) {
        return TeamB;
    } else {
        return NoTeam;
    }
}

-(void) startNewRound
{
    self.gameDeck = [Deck initDeck];
    for (Player *aPlayer in self.players) {
        [aPlayer preparePlayerForNewRound];
    }
    self.dealer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(dealCardsWithDeck:) userInfo:self.gameDeck repeats:YES];
}

-(void) addToCenterCardPile : (Card *) aCard
{
    [self.gameDeck addToCenterCardPileCard:aCard];
}

-(NSInteger) getCenterCardPileCount
{
    return [self.gameDeck getCenterCardPileCount];
}

-(void) removeCenterCardPileBottomCard
{
    [self.gameDeck removeCenterCardPileBottomCard];
}

-(Card *) getCenterCardPileBottomCard
{
    return [self.gameDeck getCenterCardPileBottomCard];
}

@end
