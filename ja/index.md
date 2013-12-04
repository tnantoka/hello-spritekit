# Sprite Kitでブロック崩し

## はじめに

みなさん、スマフォのゲームは好きですか？
僕は、

* 片手で操作できる
* 画面は縦向き
* 2D
* 短時間でプレイできる
* 音なしでも楽しめる
* 側近的な奴がスタミナとかガチャとか言い出さない

ような、電車やトイレでサクッと遊べるゲームが好きです。

今日は、そんなお手軽ゲームの代表的存在**ブロック崩し**をSprite Kitで作ってみます。  

こちらが完成イメージです。

![](http://tnantoka.github.io/hello-spritekit/images/play.gif)

## Sprite Kitとは

Sprite Kitとは、iOS・Mac OS X向けの2Dゲームを作るための、Apple純正フレームワークです。

### メリット
* OS標準機能
* UIKit・AppKitと連携しやすい
* 物理演算やパーティクルが簡単

### デメリット
* iOS 7, Max OS X 10.9以降が必要
* Andoroid対応不可（[Cocos2d-x](http://www.cocos2d-x.org/)で作りましょう）
* 3D未対応（[Unity](http://unity3d.com/)で作りましょう）
* 機能不足（結局[Kobold Kit](http://koboldkit.com/)などの助けが欲しくなるかも）

### メリット？デメリット？？
* 大きなアップデートは年1回（変更に振り回されずには済むけど、他のフレームワークの進化に置いていかれる）

という感じでしょうか。

## 主な登場人物

以下が、Sprite Kitに登場する主な要素です。  
他にもありますが、ひとまずこのあたりを知っていれば、あとはリファレンスを見ながら開発できます。

![](http://tnantoka.github.io/hello-spritekit/images/figure.png)

\# | 要素 | 説明 
--- | --- | --- 
1 | SKView | UIViewのサブクラス。Sprite Kitの描画を担当します。
2 | SKScene | ゲームの1画面に相当。この中にいろいろな子ノードを追加してゲーム画面を作っていきます。
3 | SKTransition | シーン遷移時のアニメーションを指定します。フェードイン・アウトやドアなど様々な種類があります。SKViewの`presentScene:transition:`メソッドで指定します。
4 | NodeCount, DrawCount, FPS | 開発用の情報表示です。SKViewの`showsDrawCount`, `showsNodeCount`, `showsFPS`をYESにすることで描画されます。
5 | SKSpriteNode | テクスチャ画像（SKTexture）を表示するためのノードです。色を指定して矩形の表示もできます。
6 | SKLabelNode | 1行のテキストを表示するノードです。
7 | SKShapeNode | CGPathを使った図形を表示するノードです。
8 | SKEmitterNode | パーティクルを表示するノードです。
9 | SKAction | ノードをアニメーションさせる時に利用します。SKNodeの`runAction:`で実行します。

なお、SKScene及び全てのノードはSKNodeのサブクラスです。`addChild:`や`runAction:`などの基本的な操作はそこから継承されています。

それでは、これらの要素を使ってゲームを作っていきます。

## プロジェクトの作成

まずはプロジェクトを作ります。

**SpriteKit Game**テンプレートも用意されていますが、今回はStoryBoardsを使わないため、**Empty Application**から作ります。  
**SpriteKit.frameWork**はXcode 5が自動でリンクしてくれるので、Build Phasesから追加する必要はありません。

まずは、ViewControllerを作ります。  
`loadView`でself.viewをSKViewに差し替えて、`viewDidLoad`で情報表示の設定をした後、`SKScene`をインスタンス化して表示します。  
また、ステータスバーも非表示にします。

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

これをAppDelegateで`rootViewController`に設定します。

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

この状態で実行すると、黒い背景にFPS等の情報だけがある画面が表示されます。

![](http://tnantoka.github.io/hello-spritekit/images/project.png)

これでSprite Kitでの開発準備が整いました。

## 初めてのシーン

最初の画面として、タイトルを表示するだけの単純な画面を作ります。  
SKSceneのサブクラスとしてTitleSceneを追加して、SKLabelNodeを1つ追加します。

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


ViewControllerでこのシーンをSKViewに表示します。

```objc:SJViewController.m
import "SJTitleScene.h"

- (void)viewDidLoad {
    /* 省略 */
    //SKScene *scene = [SKScene sceneWithSize:self.view.bounds.size];
    SKScene *scene = [SJTitleScene sceneWithSize:self.view.bounds.size];
    /* 省略 */
}
```

これで中央に**BREAKOUT!**と表示される画面ができました。

![](http://tnantoka.github.io/hello-spritekit/images/title.png)


## ブロックの表示

それでは、ブロックを表示しましょう。

まず、設定をJSON（pistを記事に貼ると読みづらいため）で書きます。

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

次にSKSceneのサブクラスとしてPlaySceneを追加し、設定を元にブロックを配置していきます。  

設定は`initialize`で読み込んで、static変数`config`に保持しています。

`addBlocks`では、幅・高さ・マージン・rowsなどから表示できるブロック数を計算して表示しています。  
また、`newBlock`の中では、ブロックの耐久力（`life`）をランダムに設定し`userData`に持たせて、それに応じて`updateBlockAplha:`メソッドで透明度を変化させています。

本来はBlockNodeをSKSpriteNodeのサブクラスとして作るべきところですが、簡略化のためSceneの中で処理しています。

また、今回は画像を使わないため`spriteNodeWithColor`で矩形にしていますが、通常は`spriteNodeWithImageNamed`や`spriteNodeWithTexture`でテクスチャ画像を指定して使います。  
なお、`SKColor`はiOSならUIColor、MacならNSColorを返してくれるマクロです。

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

そして、TitleSceneをタップするとPlaySceneに遷移するようにします。  
Transitionは上にスライドするものを指定しています。

なお、今回はSKSceneでタップをハンドルするため明示的に設定していませんが、ノードでタップを受け付ける時は、`userInteractionEnabled`をYESにするのを忘れないようにしましょう。

```objc:SJTitleScene.m
#import "SJPlayScene.h"

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKScene *scene = [SJPlayScene sceneWithSize:self.size];
    SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionUp duration:1.0f];
    [self.view presentScene:scene transition:transition];
}
```

これでブロックが表示されました。

![](http://tnantoka.github.io/hello-spritekit/images/block.png)

## パドルとボール

次はパドルとボールを表示して、タップでパドルを移動するところまで実装します。

パドルとボール用の設定を追加します。

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

`addPaddle`で設定を元にパドルを表示します。

画面がタップされたときにボールがなければ、`addBall`を呼び出してボールを追加します。  
ボールがあればプレイ中と判断し、パドルを等速度で動かします。  

パドルやボールは`name`に設定した値を元に`childNodeWithName:`で探索しています。（インスタンス変数に保持しても良い）  
パドルの移動はSKActionで行なっています。

```objc:SJPlayScene.m

- (id)initWithSize:(CGSize)size {
        /* 省略 */
        [self addPaddle];
        /* 省略 */
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

これでパドルが表示され、

* 1度目のタップでボールを表示
* 2度目以降のタップでパドルが移動

できるようになりました。

![](http://tnantoka.github.io/hello-spritekit/images/paddle.png)



## 物理演算と当たり判定

Sprite Kitには物理エンジンが内蔵されています。

ノードに`physicsBody`を設定すれば物理エンジンで管理されるようになるため、それだけで物理法則にしたがって動いてくれます。この簡単さが物理エンジンがビルトインされているメリットです。

まずは、設定に`speed`と`velocity`を追加します。

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


次にシーン、ブロック、パドル、ボールそれぞれに`physicsBody`を設定します。これだけでノードが重力の影響を受けるようになり、ノード同士が衝突（collision)するようになります。

以下の画像の赤枠が、`physicsBody`の設定されている箇所です。

![](http://tnantoka.github.io/hello-spritekit/images/physics.png)

なお、この枠は[PhysicsDebugger](https://github.com/ymc-thzi/PhysicsDebugger)で描画しています。

```ruby:Podfile
pod 'PhysicsDebugger', git: 'https://github.com/ymc-thzi/PhysicsDebugger.git'
```

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

とすれば利用できます。

`physicsBody`をただ設定するだけだと、全てのノードが重力によって落下していくだけです。ゲームとして成立するように設定を行ないましょう。

ブロック・パドルは固定するため`dynamic`をNOにしています。

ボールは、**固定はしないが重力は無視**するため、`affectedByGravity`をNOにして、`velocity`で力を加えて動かしています。  
また、`restitution`を1.0fにすることで、跳ね返る時に力が減衰しないように、`linearDamping`、`friction`はそれぞれ0にして空気抵抗をなくしています。

`usesPreciseCollisionDetection`をYESにすることで、衝突判定が正確になります。
 
`categoryBitMask`はノードのタイプを判別するためのビットマスクです。`contactTestBitMask`に設定したものと接触（contact）した場合、`didBeginContact:`が呼ばれます。
delegateはシーンの`physicsWorld.contactDelegate`で設定します。
今回はselfを指定し、その中でブロックの耐久力を減らしています。

なお、delegateメソッドに渡されるオブジェクトは順不同のため、categoryBitMaskで並び替えてから処理する必要があります。

```objc:SJPlayScene.m
static const uint32_t blockCategory = 0x1 << 0;
static const uint32_t ballCategory = 0x1 << 1;

@interface SJPlayScene () <SKPhysicsContactDelegate>
@end

- (id)initWithSize:(CGSize)size {
        /* 省略 */        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsWorld.contactDelegate = self;
        /* 省略 */
}

# pragma mark - Block

- (SKNode *)newBlock {
    /* 省略 */    
    block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.size];
    block.physicsBody.dynamic = NO;
    block.physicsBody.categoryBitMask = blockCategory;
    /* 省略 */    
}

- (void)decreaseBlockLife:(SKNode *)block {
    int life = [block.userData[@"life"] intValue] - 1;
    block.userData[@"life"] = @(life);
    [self updateBlockAlpha:block];
}

# pragma mark - Paddle

- (void)addPaddle {
    /* 省略 */    
    paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:paddle.size];
    paddle.physicsBody.dynamic = NO;
    /* 省略 */    
}

# pragma mark - Ball

- (void)addBall {
    /* 省略 */    
    CGFloat velocityX = [config[@"ball"][@"velocity"][@"x"] floatValue];
    CGFloat velocityY = [config[@"ball"][@"velocity"][@"y"] floatValue];
    /* 省略 */    
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    ball.physicsBody.affectedByGravity = NO;
    ball.physicsBody.velocity = CGVectorMake(velocityX, velocityY);
    ball.physicsBody.restitution = 1.0f;
    ball.physicsBody.linearDamping = 0;
    ball.physicsBody.friction = 0;
    ball.physicsBody.usesPreciseCollisionDetection = YES;
    ball.physicsBody.categoryBitMask = ballCategory;
    ball.physicsBody.contactTestBitMask = blockCategory;
    /* 省略 */    
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

ようやくゲームらしくなってきました。

![](http://tnantoka.github.io/hello-spritekit/images/hit.png)

### collisionとcontact
collision（衝突）はその物体に触れた時に跳ね返るか、contact（接触）はdelegateが呼ばれるか、です。
ちょっと日本語のイメージと逆な気もします。いわゆる**当たり判定**はcontactの方ですね。

それぞれ`collisionTestBitMask`と`contactTestBitMask`で設定します。
デフォルトではcollisionは全てのノードと、contactは無しになっているようです。

例えばボールの`collisionTestBitMask`でブロックを指定しないようにすると、以下のGIFのように貫通する表現ができます。（`contactTestBitMask`は設定したままなのでブロックは破壊されます）

![](http://tnantoka.github.io/hello-spritekit/images/collision.gif)


## パーティクルで爆発

終盤にさしかかってきました。
ここで少し演出を加えてみましょう。

パーティクルは、細かい粒子によって、炎や水といった自然界の曖昧なものを表現する技術です。Sprite Kitでは、これを簡単に作るためのノード（SKEmitterNode）やエディタ（[Particle Emitter Editor](https://developer.apple.com/LIBRARY/IOS/documentation/IDEs/Conceptual/xcode_guide-particle_emitter/Introduction/Introduction.html)）が用意されています。

New File…からファイルを追加します。  
Resourceから**SpriteKit Particle File**を選択し、Particle templateは**Spark**、ファイル名は`spark.sks`とします。

すると以下のような**sks**ファイルが作られます。

![](http://tnantoka.github.io/hello-spritekit/images/particle.png)

これを、ブロックの破壊時にブロックの座標に表示して、すぐフェードアウトさせます。

```objc:SJPlayScene.m
# pragma mark - Block

- (void)decreaseBlockLife:(SKNode *)block {
    /* 省略 */
    if (life < 1) {
        [self removeNodeWithSpark:block];
    }
    /* 省略 */
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

これでブロックの耐久力が0になると、爆発と共に消滅するようになりました。

![](http://tnantoka.github.io/hello-spritekit/images/spark.png)

## 仕上げ

最後に、もう少しゲームらしくなるように調整しましょう。

ラベルとライフ（残機）の設定を追加します。

```js:config.json
    "label" : {
        "margin" : 5.0,
        "font_size" : 14.0
    },
    "max_life" : 5
```

ライフと何ステージ目かを保持するプロパティと、イニシャライザを追加します。

```objc:SJPlayScene.h
@property (nonatomic) int life;
@property (nonatomic) int stage;
- (id)initWithSize:(CGSize)size life:(int)life stage:(int)stage;
```

`initWithSize:`は`initWithSize:life:stage:`を呼び出すように変更します。
イニシャライザの中で、ライフやステージを表示するSKLabelNodeも追加しています。

なお、ノードは`addChild:`されたのが遅いほど前面に表示されるため、何も設定しないと下記のようにラベルが隠れてしまいます。

![](http://tnantoka.github.io/hello-spritekit/images/z_position.png)

今回ラベルには`zPosition`を設定して、あとから追加されるボールよりも手前に表示されるようにしています。（zPositionの小さい順に描画され、デフォルトは0.0のため）

また、ボールの`velocity`に`self.stage`をプラスしてステージが進むごとに難易度をあげています。

`blockNodes`が0になればステージクリアとして、PlaySceneをもう一度表示します。


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
        /* 省略 */
        if ([self blockNodes].count < 1) {
            [self nextLevel];
        }
        /* 省略 */
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
    /* 省略 */
    ball.physicsBody.velocity = CGVectorMake(velocityX + self.stage, velocityY + self.stage);
    /* 省略 */
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

`Callbacks`の部分では、Sprite Kitによるフレーム毎の処理に後に微調整を加えています。
Sprite Kitのゲームループは、以下の画像のようになっており、緑色の部分で独自処理をはさむことができます。

![](http://tnantoka.github.io/hello-spritekit/images/ja/chart.png)


今回は、`update:`で5秒ごとにボールの速度をはやめています。  
`didEvaluateActions`では、アクションにより画面外に行ってしまうパドルを画面内に収めています。  
`didSimulatePhysics`では、ボールが画面最下部に行った時に破壊して、ライフを減らす処理をしています。0になればゲームオーバーを表示します。


ゲームオーバー用のシーンは、ほぼタイトル画面と同じです。

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

これで、ライフが0になると**GAME OVER…**と表示されます。タップでリトライします。

![](http://tnantoka.github.io/hello-spritekit/images/game_over.png)

## できあがり

これで完成です。  
PlaySceneが約300行、その他のファイルは数十行です。
とても短い、というわけではないですが、十分お手軽ではないでしょうか。

ちなみに僕は今、[RPGのリリースに向け悪戦苦闘中](http://spritekit.jp/)です。皆さんもSprite Kitでゲーム作成してみませんか。

## ソースコード

[tnantoka/hello-spritekit](https://github.com/tnantoka/hello-spritekit)にて公開しています。  
ライセンスはThe MIT Licenseですので、ご自由にどうぞ。  
スターしてくれたら喜びます！

## 参考
* [Sprite Kit Programming Guide](https://developer.apple.com/library/IOs/documentation/GraphicsAnimation/Conceptual/SpriteKit_PG/Introduction/Introduction.html)  
残念ながら、[日本語訳](https://developer.apple.com/jp/devcenter/ios/library/japanese.html)はまだ提供されていません。
* [Sprite Kit Framework Reference](https://developer.apple.com/Library/ios/documentation/SpriteKit/Reference/SpriteKitFramework_Ref/_index.html)





