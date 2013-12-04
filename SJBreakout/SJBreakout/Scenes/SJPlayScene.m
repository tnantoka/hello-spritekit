//
//  SJPlayScene.m
//  SJBreakout
//
//  Created by Tatsuya Tobioka on 11/30/13.
//  Copyright (c) 2013 tnantoka. All rights reserved.
//

#import "SJPlayScene.h"

#import "SJGameOverScene.h"

#ifdef DEBUG
#import "YMCPhysicsDebugger.h"
#endif

static const uint32_t blockCategory = 0x1 << 0;
static const uint32_t ballCategory = 0x1 << 1;
static const uint32_t paddleCategory = 0x1 << 2;
static const uint32_t worldCategory = 0x1 << 3;

@interface SJPlayScene () <SKPhysicsContactDelegate>
@end

@implementation SJPlayScene

- (id)initWithSize:(CGSize)size life:(int)life stage:(int)stage {
    self = [super initWithSize:size];
    if (self) {
        self.life = life;
        self.stage = stage;

#ifdef DEBUG
        //[YMCPhysicsDebugger init];
#endif

        [self addBlocks];
        [self addPaddle];
        
        [self addStageLabel];
        [self addLifeLabel];
        [self updateLifeLabel];
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsWorld.contactDelegate = self;
        self.physicsBody.categoryBitMask = worldCategory;

#ifdef DEBUG
        /*
        SKSpriteNode *dummy = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:self.size];
        dummy.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        dummy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:dummy.size];
        dummy.physicsBody.dynamic = NO;
        [self addChild:dummy];
         */
        //[self drawPhysicsBodies];
#endif
    }
    return self;
}

- (id)initWithSize:(CGSize)size {
    return [self initWithSize:size life:[config[@"max_life"] intValue] stage:1];
}

static NSDictionary *config = nil;
+ (void)initialize {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!config) {
        config = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    }
}

# pragma mark - Block

- (void)addBlocks {
    
    int rows = [config[@"block"][@"rows"] intValue];
    CGFloat margin = [config[@"block"][@"margin"] floatValue];
    CGFloat width = [config[@"block"][@"width"] floatValue];
    CGFloat height = [config[@"block"][@"height"] floatValue];
    
    int cols = floor(CGRectGetWidth(self.frame) - margin) / (width + margin);
    
    CGFloat y = CGRectGetHeight(self.frame) - margin - height / 2;
    
    for (int i = 0; i < rows; i++) {
        CGFloat x = margin + width / 2;
        for (int j = 0; j < cols; j++) {
            SKNode *block = [self newBlock];
            block.position = CGPointMake(x, y);
            x += width + margin;
        }
        y -= height + margin;
    }
}

- (SKNode *)newBlock {
    CGFloat width = [config[@"block"][@"width"] floatValue];
    CGFloat height = [config[@"block"][@"height"] floatValue];
    int maxLife = [config[@"block"][@"max_life"] floatValue];

    SKSpriteNode *block = [SKSpriteNode spriteNodeWithColor:[SKColor cyanColor] size:CGSizeMake(width, height)];
    block.name = @"block";

    int life = (arc4random() % maxLife) + 1;
    block.userData = @{ @"life" : @(life) }.mutableCopy;
    [self updateBlockAlpha:block];
    
    block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.size];
    block.physicsBody.dynamic = NO;
    block.physicsBody.categoryBitMask = blockCategory;

    [self addChild:block];

    return block;
}

- (void)updateBlockAlpha:(SKNode *)block {
    int life = [block.userData[@"life"] intValue];
    block.alpha = life * 0.2f;
}

- (void)decreaseBlockLife:(SKNode *)block {
    int life = [block.userData[@"life"] intValue] - 1;
    block.userData[@"life"] = @(life);
    [self updateBlockAlpha:block];
    
    if (life < 1) {
        [self removeNodeWithSpark:block];
        /*
         for (SKNode *node in [self blockNodes]) {
         [self removeNodeWithSpark:node];
         }
         */
        if ([self blockNodes].count < 1) {
            [self nextLevel];
        }
    }
}

- (NSArray *)blockNodes {
    NSMutableArray *nodes = @[].mutableCopy;
    [self enumerateChildNodesWithName:@"block" usingBlock:^(SKNode *node, BOOL *stop) {
        [nodes addObject:node];
    }];
    return nodes;
}

# pragma mark - Paddle

- (void)addPaddle {
    CGFloat width = [config[@"paddle"][@"width"] floatValue];
    CGFloat height = [config[@"paddle"][@"height"] floatValue];
    CGFloat y = [config[@"paddle"][@"y"] floatValue];
    
    SKSpriteNode *paddle = [SKSpriteNode spriteNodeWithColor:[SKColor brownColor] size:CGSizeMake(width, height)];
    paddle.name = @"paddle";
    paddle.position = CGPointMake(CGRectGetMidX(self.frame), y);
    
    paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:paddle.size];
    paddle.physicsBody.dynamic = NO;
    paddle.physicsBody.categoryBitMask = paddleCategory;

    [self addChild:paddle];
}

- (SKNode *)paddleNode {
    return [self childNodeWithName:@"paddle"];
}

# pragma mark - Ball

- (void)addBall {
    CGFloat radius = [config[@"ball"][@"radius"] floatValue];
    CGFloat velocityX = [config[@"ball"][@"velocity"][@"x"] floatValue];
    CGFloat velocityY = [config[@"ball"][@"velocity"][@"y"] floatValue];

    SKShapeNode *ball = [SKShapeNode node];
    ball.name = @"ball";
    ball.position = CGPointMake(CGRectGetMidX([self paddleNode].frame), CGRectGetMaxY([self paddleNode].frame) + radius);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, 0, 0, radius, 0, M_PI * 2, YES);
    ball.path = path;
    ball.fillColor = [SKColor yellowColor];
    ball.strokeColor = [SKColor clearColor];

    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    ball.physicsBody.affectedByGravity = NO;
    ball.physicsBody.velocity = CGVectorMake(velocityX + self.stage, velocityY + self.stage);
    ball.physicsBody.restitution = 1.0f;
    ball.physicsBody.linearDamping = 0;
    ball.physicsBody.friction = 0;
    ball.physicsBody.usesPreciseCollisionDetection = YES;
    ball.physicsBody.categoryBitMask = ballCategory;
    ball.physicsBody.contactTestBitMask = blockCategory;
    //ball.physicsBody.collisionBitMask = paddleCategory | worldCategory;
    
    CGPathRelease(path);

    [self addChild:ball];
}

- (SKNode *)ballNode {
    return [self childNodeWithName:@"ball"];
}

# pragma mark - Label

- (void)addStageLabel {
    CGFloat margin = [config[@"label"][@"margin"] floatValue];
    CGFloat fontSize = [config[@"label"][@"font_size"] floatValue];

    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Bold"];
    label.text = [NSString stringWithFormat:@"STAGE %d", _stage];
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    label.position = CGPointMake(CGRectGetMaxX(self.frame) - margin, CGRectGetMaxY(self.frame) - margin);
    label.fontSize = fontSize;
    label.zPosition = 1.0f;
    [self addChild:label];
}

- (void)addLifeLabel {
    CGFloat margin = [config[@"label"][@"margin"] floatValue];
    CGFloat fontSize = [config[@"label"][@"font_size"] floatValue];

    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"HiraKakuProN-W3"];
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    label.position = CGPointMake(margin, CGRectGetMaxY(self.frame) - margin);
    label.fontSize = fontSize;
    label.zPosition = 1.0f;
    label.color = [SKColor magentaColor];
    label.colorBlendFactor = 1.0f;
    label.name = @"lifeLabel";
    [self addChild:label];
}

- (void)updateLifeLabel {
    NSMutableString *s = @"".mutableCopy;
    for (int i = 0; i < _life; i++) {
        [s appendString:@"♥"];
    }
    [self lifeLabel].text = s;
}

- (SKLabelNode *)lifeLabel {
    return (SKLabelNode *)[self childNodeWithName:@"lifeLabel"];
}

# pragma mark - Callbacks

- (void)update:(NSTimeInterval)currentTime {
    if((int)currentTime % 5 == 0) {
        CGVector velocity = [self ballNode].physicsBody.velocity;
        velocity.dx *= 1.001f;
        velocity.dy *= 1.001f;
        [self ballNode].physicsBody.velocity = velocity;
    }
}

- (void)didEvaluateActions {
    CGFloat width = [config[@"paddle"][@"width"] floatValue];

    CGPoint paddlePosition = [self paddleNode].position;
    if (paddlePosition.x < width / 2) {
        paddlePosition.x = width / 2;
    } else if (paddlePosition.x > CGRectGetWidth(self.frame) - width / 2) {
        paddlePosition.x = CGRectGetWidth(self.frame) - width / 2;
    }
    [self paddleNode].position = paddlePosition;
}

- (void)didSimulatePhysics {
    if ([self ballNode] && [self ballNode].position.y < [config[@"ball"][@"radius"] floatValue] * 2) {
        [self removeNodeWithSpark:[self ballNode]];
        _life--;
        [self updateLifeLabel];
        if (_life < 1) {
            [self gameOver];
        }
    }
}

# pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if (firstBody.categoryBitMask & blockCategory) {
        if (secondBody.categoryBitMask & ballCategory) {
            [self decreaseBlockLife:firstBody.node];
        }
    }
}

# pragma mark - Touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    if (![self ballNode]) {
        [self addBall];
        return;
    }

    UITouch *touch = [touches anyObject];
    CGPoint locaiton = [touch locationInNode:self];

    CGFloat speed = [config[@"paddle"][@"speed"] floatValue];

    CGFloat x = locaiton.x;
    CGFloat diff = abs(x - [self paddleNode].position.x);
    CGFloat duration = speed * diff;
    SKAction *move = [SKAction moveToX:x duration:duration];
    [[self paddleNode] runAction:move];
}

# pragma mark - Utilities

- (void)removeNodeWithSpark:(SKNode *)node {
    NSString *sparkPath = [[NSBundle mainBundle] pathForResource:@"spark" ofType:@"sks"];
    SKEmitterNode *spark = [NSKeyedUnarchiver unarchiveObjectWithFile:sparkPath];
    spark.position = node.position;
    spark.xScale = spark.yScale = 0.3f;
    [self addChild:spark];
    
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.3f];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *sequence = [SKAction sequence:@[fadeOut, remove]];
    [spark runAction:sequence];
    
    [node removeFromParent];
}

- (void)gameOver {
    SKScene *scene = [SJGameOverScene sceneWithSize:self.size];
    SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionDown duration:1.0f];
    [self.view presentScene:scene transition:transition];
}

- (void)nextLevel {
    SJPlayScene *scene = [[SJPlayScene alloc] initWithSize:self.size life:self.life stage:self.stage + 1];
    SKTransition *transition = [SKTransition doorwayWithDuration:1.0f];
    [self.view presentScene:scene transition:transition];
}

@end
