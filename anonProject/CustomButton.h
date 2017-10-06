//
//  CustomButton.h
//  anonProject
//
//  Created by Nikos Grigoriadis on 10/6/17.
//  Copyright © 2017 anon. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSInteger, ButtonTypeIdentifier) {
    MenuButton
};

@interface CustomButton : SKSpriteNode

@property ButtonTypeIdentifier buttonType;

-(void) initButtonWithType : (ButtonTypeIdentifier) buttonType;

@end
