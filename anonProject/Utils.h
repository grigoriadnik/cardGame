//
//  Utils.h
//  anonProject
//
//  Created by Nikos Grigoriadis on 6/25/17.
//  Copyright © 2017 anon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PlayerTeam) {
    NoTeam,
    TeamA,
    TeamB
};

@interface Utils : NSObject

+ (int)getRandomNumberBetween:(NSInteger)from to:(NSInteger)to;

@end
