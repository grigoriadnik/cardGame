//
//  GameMenuView.h
//  anonProject
//
//  Created by Nikos Grigoriadis on 10/9/17.
//  Copyright © 2017 anon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "GameMenuViewDelegate.h"

@interface GameMenuView : UIView

+(GameMenuView *) initControllerForFrame : (CGRect) aFrame listener : (SKScene<GameMenuViewDelegate>*) listener;

@property (weak, nonatomic) IBOutlet UIButton *resumeButton;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;

@property (nonatomic, weak) id<GameMenuViewDelegate> gameMenuDelegate;

- (IBAction)resumeAction:(id)sender;
- (IBAction)exitAction:(id)sender;

@end
