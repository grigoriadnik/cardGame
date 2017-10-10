//
//  GameViewController.h
//  anonProject
//
//  Created by Nikolaos Grigoriadis on 1/18/16.
//  Copyright © 2016 anon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "NavigationDelegates.h"
#import "GameScene.h"

@interface GameViewController : UIViewController < NavigationDelegates >

@property BOOL justOnce;
@property int numOfPlayers;

@property GameScene *gameScene;
@property SKView *skView;

@end
