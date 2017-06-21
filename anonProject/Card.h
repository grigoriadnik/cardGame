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
@property NSInteger number;
@property SKTexture *cardTexture;
/*
 normal - 1
 jack   - 2
 */
@property NSInteger powerType;

/*
    2 of clubs     - 2 points
    10 of diamonds - 3 points
    ace            - 1 point
    jack           - 1 point
    else           - 0 points
 */
@property NSInteger pointsWorth;

-(BOOL) isFocused;
-(NSInteger) getNumber;
-(NSInteger) getPointsWorth;
-(SKTexture *) getCardTexture;
-(void) initCardWithNumber :(NSInteger) number powerType : (NSInteger) powerType pointsWorth : (NSInteger) pointsWorth cardImageString : (NSString *) cardImage isFocused : (BOOL) isFocused;

@end
