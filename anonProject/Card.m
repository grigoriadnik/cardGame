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

-(int) getNumber
{
    return self.number;
}

-(int) getPointsWorth
{
    return self.pointsWorth;
}

@end
