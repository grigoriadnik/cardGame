//
//  Card.m
//  anonProject
//
//  Created by Nikolaos Grigoriadis on 1/14/16.
//  Copyright © 2016 anon. All rights reserved.
//

#import "Card.h"

@implementation Card

-(BOOL) isFocused
{
    return self.focused;
}

-(NSInteger) getNumber
{
    return self.number;
}

-(NSInteger) getPointsWorth
{
    return self.pointsWorth;
}

-(SKTexture *) getCardTexture
{
    return self.cardTexture;
}

-(void) initCardWithNumber :(NSInteger) number powerType : (NSInteger) powerType pointsWorth : (NSInteger) pointsWorth cardImageString : (NSString *) cardImage isFocused : (BOOL) isFocused
{
    self.number = number;
    self.pointsWorth = pointsWorth;
    self.powerType = powerType;
    self.focused = isFocused;
    self.cardTexture =  [SKTexture textureWithImage:[UIImage imageNamed:cardImage]];
}

@end
