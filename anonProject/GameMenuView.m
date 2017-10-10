//
//  GameMenuView.m
//  anonProject
//
//  Created by Nikos Grigoriadis on 10/9/17.
//  Copyright © 2017 anon. All rights reserved.
//
#define MenuWidth 300
#define MenuHeight 200

#import "GameMenuView.h"

@implementation GameMenuView

+(GameMenuView *) initControllerForFrame : (CGRect) aFrame listener : (SKScene<GameMenuViewDelegate>*) listener
{
    GameMenuView *newView = [[GameMenuView alloc] init];
    newView  = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] firstObject];
    newView.gameMenuDelegate = listener;
    
    CGFloat originX = aFrame.size.width/2.0 - MenuWidth/2.0;
    CGFloat originY = aFrame.size.height/2.0 - MenuHeight/2.0;
    //237-54-5
    [newView setFrame:CGRectMake(originX, originY, MenuWidth, MenuHeight)];
    
    newView.resumeButton.layer.cornerRadius = 5.0;
    newView.resumeButton.layer.borderWidth = 1.0;
    newView.resumeButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    newView.exitButton.layer.cornerRadius = 5.0;
    newView.exitButton.layer.borderWidth = 1.0;
    newView.exitButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    newView.layer.cornerRadius = 15.0;
    newView.layer.borderWidth = 2.0;
    newView.layer.borderColor = [UIColor colorWithRed:237.0/255.0 green:54.0/255.0 blue:5.0/255.0 alpha:1.0].CGColor;
    
    return newView;
}

- (IBAction)resumeAction:(id)sender
{
    if(self.gameMenuDelegate!=nil){
        [self.gameMenuDelegate userSelectedOption:ResumeOption];
    }
}

- (IBAction)exitAction:(id)sender
{
    if(self.gameMenuDelegate != nil) {
        [self.gameMenuDelegate userSelectedOption:ExitOption];
    }
}

@end
