//
//  GameScene.h
//  anonProject
//

//  Copyright (c) 2015 anon. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Deck.h"
#import "Player.h"
#import "GameHandler.h"

@interface GameScene : SKScene < GameHandlerDelegate >

@property NSTimer *aTimer;
@property int cardCounter;
@property BOOL gameStart;
@property int playsNowIndex;//1- player, 2- CPU, 3- CPU, 4- CPU
@property int numOfPlayers;
@property BOOL startNewHand;
@property GameHandler *gameHandler;
@property NSMutableDictionary *imageForCardNameDict;

@property (nonatomic,strong) SKLabelNode *teamAScoreLabel;
@property (nonatomic,strong) SKLabelNode *teamBScoreLabel;

@end
