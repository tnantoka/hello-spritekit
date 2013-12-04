//
//  SJTitleScene.m
//  SJBreakout
//
//  Created by Tatsuya Tobioka on 11/29/13.
//  Copyright (c) 2013 tnantoka. All rights reserved.
//

#import "SJTitleScene.h"

#import "SJPlayScene.h"

@implementation SJTitleScene

- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        SKLabelNode *titleLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        titleLabel.text = @"BREAKOUT!";
        titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        titleLabel.fontSize = 50.0f;
        [self addChild:titleLabel];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKScene *scene = [SJPlayScene sceneWithSize:self.size];
    SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionUp duration:1.0f];
    [self.view presentScene:scene transition:transition];
}

@end
