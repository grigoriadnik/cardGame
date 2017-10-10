//
//  GameViewController.m
//  anonProject
//
//  Created by Nikolaos Grigoriadis on 7/9/15.
//  Copyright (c) 2015 anon. All rights reserved.
//

#import "MainMenu.h"
#import "GameViewController.h"
#import "UIImage+animatedGIF.h"

@implementation MainMenu

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.twoPlayersButton.hidden=YES;
    self.fourPlayersButton.hidden=YES;
    self.justOnce=false;
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.theNewGameButton.layer.cornerRadius=15.0;
    self.theNewGameButton.layer.masksToBounds=YES;
    self.theNewGameButton.layer.borderWidth=1.0;
    self.theNewGameButton.layer.borderColor=[UIColor whiteColor].CGColor;//[UIColor colorWithRed:70/255.0 green:31/255.0 blue:0/255.0 alpha:1.0].CGColor;
    
    self.multiplayerButton.layer.cornerRadius=15.0;
    self.multiplayerButton.layer.masksToBounds=YES;
    self.multiplayerButton.layer.borderWidth=1.0;
    self.multiplayerButton.layer.borderColor=[UIColor whiteColor].CGColor;
    
    self.rulesButton.layer.cornerRadius=15.0;
    self.rulesButton.layer.masksToBounds=YES;
    self.rulesButton.layer.borderWidth=1.0;
    self.rulesButton.layer.borderColor=[UIColor whiteColor].CGColor;
    
    self.twoPlayersButton.layer.cornerRadius=15.0;
    self.twoPlayersButton.layer.masksToBounds=YES;
    
    self.fourPlayersButton.layer.cornerRadius=15.0;
    self.fourPlayersButton.layer.masksToBounds=YES;
    
    if(!self.justOnce)
    {
        NSData *gifData=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dancingCard" ofType:@"gif"]];
        [self.dancingCardButton setImage:[self processImage:[UIImage animatedImageWithAnimatedGIFData:gifData]] forState:UIControlStateNormal];
        [self.dancingCardButton setImage:[self processImage:[UIImage animatedImageWithAnimatedGIFData:gifData]] forState:UIControlStateHighlighted];
        [self.dancingCardButton setImage:[self processImage:[UIImage animatedImageWithAnimatedGIFData:gifData]] forState:UIControlStateDisabled];
        self.justOnce=!self.justOnce;
    }
}

- (UIImage*) processImage :(UIImage*) image
{
    CGFloat colorMasking[6]={224,255,224,255,224,255};
    CGImageRef imageRef = CGImageCreateWithMaskingColors(image.CGImage, colorMasking);
    UIImage* imageB = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return imageB;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)newGamePressed:(id)sender
{
    [self.theNewGameButton setTitle:@"" forState:UIControlStateNormal];
    [self.theNewGameButton setTitle:@"" forState:UIControlStateHighlighted];
    [self.theNewGameButton setTitle:@"" forState:UIControlStateDisabled];
    
    self.theNewGameButton.layer.borderColor=[UIColor clearColor].CGColor;
    self.theNewGameButton.layer.borderWidth=0.0;
    self.theNewGameButton.layer.masksToBounds=YES;
    
    self.fourPlayersButton.layer.borderColor=[UIColor clearColor].CGColor;
    self.fourPlayersButton.layer.borderWidth=0.0;
    self.fourPlayersButton.layer.masksToBounds=YES;
    
    self.twoPlayersButton.layer.borderColor=[UIColor clearColor].CGColor;
    self.twoPlayersButton.layer.borderWidth=0.0;
    self.twoPlayersButton.layer.masksToBounds=YES;
    [self.view layoutIfNeeded];
    
    self.twoPlayersButton.hidden=NO;
    self.fourPlayersButton.hidden=NO;
    self.theNewGameButton.hidden=YES;
    
    self.twoPlayersButtonWidth.constant=135;
    self.fourPlayersButtonWidth.constant=135;
    
    //self.fourPlayersButton.center = CGPointMake(self.fourPlayersButton.frame.size.width, self.fourPlayersButton.frame.size.height/2.0);
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }completion:^(BOOL completed)
     {
          dispatch_async(dispatch_get_main_queue(), ^{
              self.twoPlayersButton.layer.borderColor   = [UIColor whiteColor].CGColor;
              self.twoPlayersButton.layer.borderWidth   = 1.0;
              self.twoPlayersButton.layer.masksToBounds = YES;
              
              self.fourPlayersButton.layer.borderColor   = [UIColor whiteColor].CGColor;
              self.fourPlayersButton.layer.borderWidth   = 1.0;
              self.fourPlayersButton.layer.masksToBounds = YES;
              
              [self.twoPlayersButton setTitle:@"2 Players" forState:UIControlStateNormal];
              [self.twoPlayersButton setTitle:@"2 Players" forState:UIControlStateHighlighted];
              [self.twoPlayersButton setTitle:@"2 Players" forState:UIControlStateDisabled];
              
              [self.fourPlayersButton setTitle:@"4 Players" forState:UIControlStateNormal];
              [self.fourPlayersButton setTitle:@"4 Players" forState:UIControlStateHighlighted];
              [self.fourPlayersButton setTitle:@"4 Players" forState:UIControlStateDisabled];
              
              [self.view layoutIfNeeded];
          });
         
     }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"2Players"])
    {
        // Get reference to the destination view controller
        GameViewController *vc = [segue destinationViewController];
        // Pass any objects to the view controller here, like...
        vc.numOfPlayers=2;
        NSLog(@"set numof players 2");
    }
    else if ([[segue identifier] isEqualToString:@"4Players"])
    {
        // Get reference to the destination view controller
        GameViewController *vc = [segue destinationViewController];
        // Pass any objects to the view controller here, like...
        vc.numOfPlayers=4;
        NSLog(@"set numof players 4");
    }
}


@end
