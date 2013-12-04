//
//  SJPlayScene.h
//  SJBreakout
//
//  Created by Tatsuya Tobioka on 11/30/13.
//  Copyright (c) 2013 tnantoka. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SJPlayScene : SKScene

@property (nonatomic) int stage;
@property (nonatomic) int life;

- (id)initWithSize:(CGSize)size life:(int)life stage:(int)stage;

@end
