//
//  GameScene.h
//  anonProject
//

//  Copyright (c) 2015 anon. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene

@property NSTimer *aTimer;
@property int cardCounter;
@property BOOL gameStart;
@property int playsNowIndex;//1- player, 2- CPU, 3- CPU, 4- CPU
@property int numOfPlayers;
@property BOOL startNewHand;
@property NSMutableArray *playerCardsList;
@property NSMutableArray *oppenent1CardsList;
@property NSMutableArray *oppenent2CardsList;
@property NSMutableArray *oppenent3CardsList;

@property NSMutableArray *deck;
@property NSMutableArray *centerCardPileList;

@property NSMutableDictionary *imageForCardNameDict;

@property NSMutableArray *playerGatheredCardsList;
@property NSMutableArray  *oppenent1GatheredCardsList;
@property NSMutableArray  *oppenent2GatheredCardsList;
@property NSMutableArray  *oppenent3GatheredCardsList;

@end
