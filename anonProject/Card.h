//
//  Card.h
//  anonProject
//
//  Created by Nikolaos Grigoriadis on 1/14/16.
//  Copyright © 2016 anon. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Card : SKSpriteNode

@property BOOL focused;
@property int number;
/*
 normal - 1
 jack   - 2
 */
@property int powerType;

/*
    2 of clubs     - 2 points
    10 of diamonds - 3 points
    ace            - 1 point
    jack           - 1 point
    else           - 0 points
 */
@property int pointsWorth;

-(BOOL) isFocused;
-(int) getNumber;
-(int) getPointsWorth;

@end
