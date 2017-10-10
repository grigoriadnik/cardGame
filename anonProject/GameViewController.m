
#import "GameViewController.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.justOnce=YES;
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.justOnce)
    {
        self.justOnce = NO;
        // Configure the view.
        self.skView = (SKView *)self.view;
        self.skView.showsFPS = YES;
        self.skView.showsNodeCount = YES;
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        self.skView.ignoresSiblingOrder = YES;
        
        // Create and configure the scene.
        self.gameScene = [GameScene unarchiveFromFile:@"GameScene"];// initWithSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
        self.gameScene.navigationDelegate = self;
        self.gameScene.scaleMode = SKSceneScaleModeAspectFill;
        // scene = GameScene(size: self.view.frame.size)
        [self.gameScene setSize : self.skView.bounds.size];
        self.gameScene.numOfPlayers=self.numOfPlayers;
        // Present the scene.
        [self.skView presentScene : self.gameScene];
        
        NSLog(@"%f %f",self.skView.frame.size.width,self.skView.frame.size.height);
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
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

-(void) exitGame
{
    [self.skView presentScene:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
