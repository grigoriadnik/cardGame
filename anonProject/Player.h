//
//  Player.h
//  anonProject
//
//  Created by Nikos Grigoriadis on 6/21/17.
//  Copyright © 2017 anon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "Utils.h"

@interface Player : NSObject

@property NSMutableArray *playerCardList;
@property NSMutableArray *playerGatheredCardList;
@property NSInteger playerIndex;
@property BOOL isCPU;
@property BOOL isUser;
@property PlayerTeam team;
@property NSInteger kseres;

+(Player *) initPlayerisCpu : (BOOL) isCPU withIndex : (NSInteger) index isUser : (BOOL) isUser team : (PlayerTeam) team;

-(NSInteger) getPlayerCardListCount;
-(NSInteger) getPlayerGatheredCardListCount;
-(Card *) getPlayerCardAtIndex : (NSInteger)index;
-(Card *) getPlayerGatheredCardAtIndex : (NSInteger) index;
-(void) removePlayerCardAtIndex : (NSInteger) index;
-(void) addToPlayerGatheredCards : (Card *) aCard;
-(void) addToPlayerCards : (Card *) aCard;
-(NSInteger) getIndexForCardNumber : (NSInteger) cardNumber;
-(void) preparePlayerForNewRound;

@end
