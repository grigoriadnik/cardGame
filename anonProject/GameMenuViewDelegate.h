//
//  GameHandlerDelegates.h
//  anonProject
//
//  Created by Nikos Grigoriadis on 6/22/17.
//  Copyright © 2017 anon. All rights reserved.
//

#ifndef GameMenuViewDelegate_h
#define GameMenuViewDelegate_h

typedef NS_ENUM(NSInteger, MenuOption) {
    ResumeOption,
    ExitOption
};

@protocol GameMenuViewDelegate

-(void) userSelectedOption : (MenuOption) anOption;

@end

#endif /* GameHandlerDelegates_h */
