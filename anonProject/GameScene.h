//
//  GameScene.h
//  anonProject
//

//  Copyright (c) 2015 anon. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Deck.h"
#import "Player.h"

@interface GameScene : SKScene

@property Deck *gameDeck;

@property NSTimer *aTimer;
@property int cardCounter;
@property BOOL gameStart;
@property int playsNowIndex;//1- player, 2- CPU, 3- CPU, 4- CPU
@property int numOfPlayers;
@property BOOL startNewHand;

@property Player *player1;
@property Player *player2;
@property Player *player3;
@property Player *player4
;
@property NSMutableDictionary *imageForCardNameDict;

@end
