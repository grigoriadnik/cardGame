//
//  GameViewController.h
//  anonProject
//

//  Copyright (c) 2015 anon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface MainMenu : UIViewController

@property BOOL justOnce;
@property (strong, nonatomic) IBOutlet UIButton *theNewGameButton;
@property (strong, nonatomic) IBOutlet UIButton *multiplayerButton;
@property (strong, nonatomic) IBOutlet UIButton *rulesButton;
@property (strong, nonatomic) IBOutlet UIButton *twoPlayersButton;
@property (strong, nonatomic) IBOutlet UIButton *fourPlayersButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *theNewGameButtonWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *twoPlayersButtonWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fourPlayersButtonWidth;

- (IBAction)newGamePressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *dancingCardButton;

@end
