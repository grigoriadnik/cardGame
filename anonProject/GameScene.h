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

@property int numOfPlayers;
@property GameHandler *gameHandler;

@property (nonatomic,strong) SKLabelNode *teamAScoreLabel;
@property (nonatomic,strong) SKLabelNode *teamBScoreLabel;
@property (nonatomic,strong) SKLabelNode *player1Label;
@property (nonatomic,strong) SKLabelNode *player2Label;
@property (nonatomic,strong) SKLabelNode *player3Label;
@property (nonatomic,strong) SKLabelNode *player4Label;
@property (nonatomic,strong) SKSpriteNode *deckCardNode;

@end
