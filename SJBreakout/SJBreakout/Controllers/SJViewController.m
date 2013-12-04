//
//  SJViewController.m
//  SJBreakout
//
//  Created by Tatsuya Tobioka on 11/29/13.
//  Copyright (c) 2013 tnantoka. All rights reserved.
//

#import "SJViewController.h"

#import "SJTitleScene.h"

@import SpriteKit;

@interface SJViewController ()

@end

@implementation SJViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    SKView *skView = [[SKView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = skView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    SKView *skView = (SKView *)self.view;
    
#ifdef DEBUG
    skView.showsDrawCount = YES;
    skView.showsNodeCount = YES;
    skView.showsFPS = YES;
#endif

    SKScene *scene = [SJTitleScene sceneWithSize:self.view.bounds.size];
    [skView presentScene:scene];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
