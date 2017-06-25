//
//  Utils.m
//  anonProject
//
//  Created by Nikos Grigoriadis on 6/25/17.
//  Copyright © 2017 anon. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (NSInteger)getRandomNumberBetween:(NSInteger)from to:(NSInteger)to
{
    
    return (NSInteger)from + arc4random() % (to-from+1);
}

@end
