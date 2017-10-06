//
//  CustomButton.m
//  anonProject
//
//  Created by Nikos Grigoriadis on 10/6/17.
//  Copyright © 2017 anon. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

-(void) initButtonWithType : (ButtonTypeIdentifier) buttonType
{
    self.buttonType = buttonType;
    
    SKShapeNode* menuButtonLayer = [SKShapeNode node];
    CGRect aFrame = self.frame;
    aFrame.origin.y = 0;
    aFrame.origin.x = 0;
    menuButtonLayer.path = CGPathCreateWithRoundedRect(aFrame, 10.0, 5.0, nil);
    menuButtonLayer.lineWidth = 2.0;
    menuButtonLayer.fillColor = [UIColor clearColor];
    menuButtonLayer.strokeColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    [menuButtonLayer setZPosition:-1.0];
    [menuButtonLayer setUserInteractionEnabled:NO];
    [self addChild:menuButtonLayer];
}

@end
