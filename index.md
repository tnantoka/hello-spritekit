# How to create a breakout clone with Sprite Kit.

## Preface

Do you like smartphone games?

I like the following type of game.

* One-handed
* Portrait
* 2D
* Short time
* Enjoy without sounds

Today, Let's create a breakout clone with Sprite Kit.

Here is a goal.
![](http://tnantoka.github.io/hello-spritekit/images/play.gif)

## What's Sprite Kit

Sprite Kit is a framework by Apple to create 2D games for iOS and Mac OS X.

### Pros
* Atandard feature
* Compatible with UIKit or AppKit
* Easy to use physics or particle

### Cons
* iOS 7 or Max OS X 10.9 required_
* non-Andoroid-compliant (Use [Cocos2d-x](http://www.cocos2d-x.org/))
* non-3D-compliant (Use [Unity](http://unity3d.com/))
* lack of features ([Kobold Kit](http://koboldkit.com/) helps you)

## Main characters

Here is the main elements with Sprite Kit.

![](http://tnantoka.github.io/hello-spritekit/images/figure.png)

\# | Name | Description
--- | --- | --- 
1 | SKView | Subclass of UIView. Rendering Sprite Kit.
2 | SKScene | Game scene like title, setting, main, etc.
3 | SKTransition | Animation between scenes. Run by `presentScene:transition:` of SKView.

4 | NodeCount, DrawCount, FPS | Information for developers. Configure by `showsDrawCount`, `showsNodeCount`, `showsFPS` of SKView。
5 | SKSpriteNode | Node with texture image (SKTexture) or colorized rect。
6 | SKLabelNode | Node with single line text.
7 | SKShapeNode | Node with CGPath shapes.
8 | SKEmitterNode | Node with particle.
9 | SKAction | Animation for nodes. Run with `runAction:` of SKNode.

SKScene and all nodes are subclass of SKNode. 

## Create a project

**SpriteKit Game** is with Storyboards. This time we don't use storyboards. So we use **Empty Application**.
**SpriteKit.frameWork** will link automatically by Xcode 5.

### ViewControlelr

* Set SKView to `self.view`.
* Show information.
* Present instance of SKScene.
* Hide status bar.

```objc:SJViewController.m
@import SpriteKit;

- (void)loadView {
    SKView *skView = [[SKView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = skView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    SKView *skView = (SKView *)self.view;    
    skView.showsDrawCount = YES;
    skView.showsNodeCount = YES;
    skView.showsFPS = YES;

    SKScene *scene = [SKScene sceneWithSize:self.view.bounds.size];
    [skView presentScene:scene];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
```

### AppDelegate

* Set ViewController to `rootViewController`.

```objc:SJAppDelegate.m
#import "SJViewController.h"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    SJViewController *viewController = SJViewController.new;
    _window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    return YES;
}
```

### Run
Show scene with black background and information. 

![](http://tnantoka.github.io/hello-spritekit/images/project.png)

Now, Sprite Kit is ready!

## First scene

Create a first scene with single line text.

### TitleScene

* Subclass of SKScene.
* Add SKLabelNode.

```objc:SJTitleScene.m
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
```

### ViewController

* Present TitleScene.

```objc:SJViewController.m
import "SJTitleScene.h"

- (void)viewDidLoad {
    /* abbr. */
    //SKScene *scene = [SKScene sceneWithSize:self.view.bounds.size];
    SKScene *scene = [SJTitleScene sceneWithSize:self.view.bounds.size];
    /* abbr. */
}
```

### Run

Show scene with **BREAKOUT!** at center.

![](http://tnantoka.github.io/hello-spritekit/images/title.png)


## Draw blocks

Write settings with JSON.

```js:config.json
{
    "block" : {
        "margin" : 16.0,
        "width" : 34.0,
        "height" : 16.0,
        "rows" : 5,
        "max_life" : 5
    },
}
```

## PlayScene

* Load settings in `initialize`.
* Create blocks with `spriteNodeWithColor`. If you use images, you can use `spriteNodeWithImageNamed` or `spriteNodeWithTexture`.
* Set life to 'userData' of block.
* Udpate alpha with block's life.

```objc:SJPlayScene.m
- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        [self addBlocks];
    }
    return self;
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
    
    [self addChild:block];

    return block;
}

- (void)updateBlockAlpha:(SKNode *)block {
    int life = [block.userData[@"life"] intValue];
    block.alpha = life * 0.2f;
}
```

### TitleScene

* Go to PlayScene with push transition by tap.

```objc:SJTitleScene.m
#import "SJPlayScene.h"

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKScene *scene = [SJPlayScene sceneWithSize:self.size];
    SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionUp duration:1.0f];
    [self.view presentScene:scene transition:transition];
}
```

### Run

Show blocks!

![](http://tnantoka.github.io/hello-spritekit/images/block.png)

## Paddle and ball

Show paddle, ball and move paddle by tap.

### Settings

* Add settings for paddle and ball.

```js:config.json
    "paddle" : {
        "width" : 70.0,
        "height" : 14.0,
        "y" : 40.0,
    },
    "ball" : {
        "radius" : 6.0,
    },
```

### PlayScene

* Add ball if ball doesn't exist by tap.
* Move paddle with SKAction by tap.

Paddle or ball are searched by `name` with  `childNodeWithName:`.

```objc:SJPlayScene.m

- (id)initWithSize:(CGSize)size {
        /* abbr. */
        [self addPaddle];
        /* abbr. */
}

# pragma mark - Paddle

- (void)addPaddle {
    CGFloat width = [config[@"paddle"][@"width"] floatValue];
    CGFloat height = [config[@"paddle"][@"height"] floatValue];
    CGFloat y = [config[@"paddle"][@"y"] floatValue];
    
    SKSpriteNode *paddle = [SKSpriteNode spriteNodeWithColor:[SKColor brownColor] size:CGSizeMake(width, height)];
    paddle.name = @"paddle";
    paddle.position = CGPointMake(CGRectGetMidX(self.frame), y);
    
    [self addChild:paddle];
}

- (SKNode *)paddleNode {
    return [self childNodeWithName:@"paddle"];
}

# pragma mark - Ball

- (void)addBall {
    CGFloat radius = [config[@"ball"][@"radius"] floatValue];

    SKShapeNode *ball = [SKShapeNode node];
    ball.name = @"ball";
    ball.position = CGPointMake(CGRectGetMidX([self paddleNode].frame), CGRectGetMaxY([self paddleNode].frame) + radius);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, 0, 0, radius, 0, M_PI * 2, YES);
    ball.path = path;
    ball.fillColor = [SKColor yellowColor];
    ball.strokeColor = [SKColor clearColor];

    CGPathRelease(path);

    [self addChild:ball];
}

- (SKNode *)ballNode {
    return [self childNodeWithName:@"ball"];
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

```

### Run

Show scene with paddle.

* First tap: Show ball
* Second tap: Move paddle

![](http://tnantoka.github.io/hello-spritekit/images/paddle.png)


## Physics and collistion detection

Sprite Kit has build in physics engine. If set 'physicsBody' to node, Sprite kit will simulate physics automatically.

It's easy to use for collision detection.

### Settings

* Add `speed`, `velocity`.

```js:config.json
    "paddle" : {
        "width" : 70.0,
        "height" : 14.0,
        "y" : 40.0,
        "speed" : 0.005
    },
    "ball" : {
        "radius" : 6.0,
        "velocity" : {
            "x" : 50.0,
            "y" : 120.0
        }
    },

```

### PlayScene

* Set 'physicsBody' to scene, blocks, paddle, ball. 
* Set 'dynaimic' is No to blocks, paddle.
* Ball is dynamic but not affected by gravity, friction etc.
* Set `categoryBitMask`, `contactTestBitMask` and `physicsWorld.contactDelegate` for contact delegate.
* Decrease block life in `didBeginContact:`. You must order nodes of contact in delegate method.

```objc:SJPlayScene.m
static const uint32_t blockCategory = 0x1 << 0;
static const uint32_t ballCategory = 0x1 << 1;

@interface SJPlayScene () <SKPhysicsContactDelegate>
@end

- (id)initWithSize:(CGSize)size {
        /* abbr. */        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsWorld.contactDelegate = self;
        /* abbr. */
}

# pragma mark - Block

- (SKNode *)newBlock {
    /* abbr. */    
    block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.size];
    block.physicsBody.dynamic = NO;
    block.physicsBody.categoryBitMask = blockCategory;
    /* abbr. */    
}

- (void)decreaseBlockLife:(SKNode *)block {
    int life = [block.userData[@"life"] intValue] - 1;
    block.userData[@"life"] = @(life);
    [self updateBlockAlpha:block];
}

# pragma mark - Paddle

- (void)addPaddle {
    /* abbr. */    
    paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:paddle.size];
    paddle.physicsBody.dynamic = NO;
    /* abbr. */    
}

# pragma mark - Ball

- (void)addBall {
    /* abbr. */    
    CGFloat velocityX = [config[@"ball"][@"velocity"][@"x"] floatValue];
    CGFloat velocityY = [config[@"ball"][@"velocity"][@"y"] floatValue];
    /* abbr. */    
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    ball.physicsBody.affectedByGravity = NO;
    ball.physicsBody.velocity = CGVectorMake(velocityX, velocityY);
    ball.physicsBody.restitution = 1.0f;
    ball.physicsBody.linearDamping = 0;
    ball.physicsBody.friction = 0;
    ball.physicsBody.usesPreciseCollisionDetection = YES;
    ball.physicsBody.categoryBitMask = ballCategory;
    ball.physicsBody.contactTestBitMask = blockCategory;
    /* abbr. */    
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
```

### Run

OK, it's a gmame.

![](http://tnantoka.github.io/hello-spritekit/images/hit.png)

#### Debug border with PhysicsDebugger

![](http://tnantoka.github.io/hello-spritekit/images/physics.png)

Draw border with [PhysicsDebugger](https://github.com/ymc-thzi/PhysicsDebugger).

##### Installation with CocoaPods

```ruby:Podfile
pod 'PhysicsDebugger', git: 'https://github.com/ymc-thzi/PhysicsDebugger.git'
```

##### How-to-use

```objc:YourScene.m
#import "YMCPhysicsDebugger.h"

- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        [YMCPhysicsDebugger init];
        /* Create scene contens */
       [self drawPhysicsBodies];
    }
}
```

#### collision and contact

All nodes are collide by default.
If `collisionTestBitMask` of ball is without block, It will pass through blocks.

![](http://tnantoka.github.io/hello-spritekit/images/collision.gif)


## Spark with particle

Sprite Kit has built in particle node (SKEmitterNode) and editor ([Particle Emitter Editor](https://developer.apple.com/LIBRARY/IOS/documentation/IDEs/Conceptual/xcode_guide-particle_emitter/Introduction/Introduction.html)).

### Particle File

* New File…
* Resource is **SpriteKit Particle File**
* Particle template is **Spark**
* File name is `spark.sks`

Here is aparticle file.

![](http://tnantoka.github.io/hello-spritekit/images/particle.png)

### PlayScene

* Show and fade out particle with remove blocks.

```objc:SJPlayScene.m
# pragma mark - Block

- (void)decreaseBlockLife:(SKNode *)block {
    /* abbr. */
    if (life < 1) {
        [self removeNodeWithSpark:block];
    }
    /* abbr. */
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
```

### Run

Explosion!

![](http://tnantoka.github.io/hello-spritekit/images/spark.png)

## Adjustment

Some adjustment for play a game.

### Settings

* Add settings for label and life.

```js:config.json
    "label" : {
        "margin" : 5.0,
        "font_size" : 14.0
    },
    "max_life" : 5
```

### PlayScene

* Add property to store life and stage.
* Add initializer with life and stage.
* Add labels. Set 'zPosition' is 1 to show foreground.
* Add velocity to change difficulty.
* Next stage if `blockNodes` is 0.

#### zPosition 

If not set `zPosition`, labels will be not foreground.

![](http://tnantoka.github.io/hello-spritekit/images/z_position.png)

```objc:SJPlayScene.h
@property (nonatomic) int life;
@property (nonatomic) int stage;
- (id)initWithSize:(CGSize)size life:(int)life stage:(int)stage;
```

```objc:SJPlayScene.m
#import "SJGameOverScene.h"

- (id)initWithSize:(CGSize)size life:(int)life stage:(int)stage {
    self = [super initWithSize:size];
    if (self) {
        self.life = life;
        self.stage = stage;

        [self addBlocks];
        [self addPaddle];
        
        [self addStageLabel];
        [self addLifeLabel];
        [self updateLifeLabel];
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}

- (id)initWithSize:(CGSize)size {
    return [self initWithSize:size life:[config[@"max_life"] intValue] stage:1];
}

# pragma mark - Block

- (void)decreaseBlockLife:(SKNode *)block {
        /* abbr. */
        if ([self blockNodes].count < 1) {
            [self nextLevel];
        }
        /* abbr. */
}

- (NSArray *)blockNodes {
    NSMutableArray *nodes = @[].mutableCopy;
    [self enumerateChildNodesWithName:@"block" usingBlock:^(SKNode *node, BOOL *stop) {
        [nodes addObject:node];
    }];
    return nodes;
}

# pragma mark - Ball

- (void)addBall {
    /* abbr. */
    ball.physicsBody.velocity = CGVectorMake(velocityX + self.stage, velocityY + self.stage);
    /* abbr. */
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

# pragma mark - Utilities

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

```

#### Callbacks

Here is game loop processing with Sprite Kit.

![](http://tnantoka.github.io/hello-spritekit/images/chart.png)

You can override `update:`, `didEvaluateActions` and `didSimulatePhysics`.

This time, use for the following.

* Increase ball speed in `update:`.
* Adjust paddle position in `didEvaluateActions`.
* Decrease life in `didSimulatePhysics`.


### GameOverScene

It is close to the same TitleScene.

```objc:SJGameOverScene.m
#import "SJPlayScene.h"

- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        SKLabelNode *titleLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        titleLabel.text = @"GAVE OVER...";
        titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        titleLabel.fontSize = 40.0f;
        [self addChild:titleLabel];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKScene *scene = [SJPlayScene sceneWithSize:self.size];
    SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionUp duration:1.0f];
    [self.view presentScene:scene transition:transition];
}

```

### Run

Show **GAME OVER…** if life is zero.

![](http://tnantoka.github.io/hello-spritekit/images/game_over.png)

## Done

It's all done.

Source code is available on [tnantoka/hello-spritekit](https://github.com/tnantoka/hello-spritekit).Licensed under the terms of the MIT license.Feel free to use.

Please give me a star!

## Documents

* [Sprite Kit Programming Guide](https://developer.apple.com/library/IOs/documentation/GraphicsAnimation/Conceptual/SpriteKit_PG/Introduction/Introduction.html)  
* [Sprite Kit Framework Reference](https://developer.apple.com/Library/ios/documentation/SpriteKit/Reference/SpriteKitFramework_Ref/_index.html)





