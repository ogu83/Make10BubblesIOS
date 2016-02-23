//
//  GameScene.m
//  Make10Bubbles
//
//  Created by Oğuz Köroğlu on 23/02/16.
//  Copyright (c) 2016 Oguz Koroglu. All rights reserved.
//

#import "GameScene.h"
#import "NumberBubble.h"
#import <AVFoundation/AVFoundation.h>

@implementation GameScene

int xMargin = 10;
int yMargin = 40;

float bubbleRadiusMinDivider = 4;
float bubbleRadiusDivider = 6;
float levelIntervalInSeconds = 3;
CFTimeInterval updatedTime;

bool gamePaused;
bool gameOver;
bool onMenu;
bool onExplode;

SKLabelNode* scoreLabel;
int score;
int nextLevelScore = 100;
bool onScoreAction = false;
bool hintsEnabled = true;
int hintCountDown = 5;

AVAudioPlayer *player;

NSMutableArray* bubbles;

- (void)createBackground
{
    [self setBackgroundColor:[SKColor colorWithRed:0.9 green:0.9 blue:1 alpha:1]];
    
    float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    
    UIImage* image = [UIImage imageNamed:@"Background"];
    //UIImage* cropped = [self cropBackgroundImage:image];
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:image]];
    sprite.size = self.frame.size;
    sprite.position = CGPointMake(frameW / 2, frameH / 2);
    sprite.zPosition = -1;
    [self addChild:sprite];
}

-(void)createBackgroundMusic
{
    if (player != nil)
    {
        [player stop];
        player = nil;
    }
    
    NSString *dataPath=[[NSBundle mainBundle] pathForResource:@"FUN_FUN_MIN_GSM" ofType:@"wav"];
    NSData* musicData = [NSData dataWithContentsOfFile:dataPath];
    player = [[AVAudioPlayer alloc] initWithData:musicData error:nil];
    player.volume = 0.5;
    player.numberOfLoops=-1;
    [player play];
}

-(void)createBackgroundEndMusic
{
    if (player != nil)
    {
        [player stop];
        player = nil;
    }
    
    NSString *dataPath=[[NSBundle mainBundle] pathForResource:@"FUN_FUN_LK1_GSM" ofType:@"wav"];
    NSData* musicData = [NSData dataWithContentsOfFile:dataPath];
    player = [[AVAudioPlayer alloc] initWithData:musicData error:nil];
    player.volume = 0.5;
    //player.numberOfLoops=-1;
    [player play];
}

-(void)createMenu
{
    onMenu = true;
    
    float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    float menuBtnW = frameW / 4;
    float menuBtnH = menuBtnW * [MenuButton buttonScaleRatio];
    
    
    _playButton = [MenuButton playButton];
    _playButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame) + menuBtnH * 1.1 * 1.5);
    [_playButton setSize:CGSizeMake(menuBtnW, menuBtnH)];
    [_playButton setZPosition:9];
    [self addChild:_playButton];
    
    
    _infoButton = [MenuButton infoButton];
    _infoButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame) + menuBtnH * 1.1 * 0.5);
    [_infoButton setSize:CGSizeMake(menuBtnW, menuBtnH)];
    [_infoButton setZPosition:9];
    [self addChild:_infoButton];
    
    
    _highScoreButton = [MenuButton highScoreButton];
    _highScoreButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame) + menuBtnH * 1.1 * -0.5);
    [_highScoreButton setSize:CGSizeMake(menuBtnW, menuBtnH)];
    [_highScoreButton setZPosition:9];
    [self addChild:_highScoreButton];
    
    
    _reviewButton = [MenuButton reviewButton];
    _reviewButton.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame) + menuBtnH * 1.1 * -1.5);
    [_reviewButton setSize:CGSizeMake(menuBtnW, menuBtnH)];
    [_reviewButton setZPosition:9];
    [self addChild:_reviewButton];
    
    
    _exitButton = [MenuButton exitButton];
    _exitButton.position = CGPointMake(frameW-xMargin-menuBtnW/2/2,
                                    frameH-yMargin-menuBtnH/2/2);
    [_exitButton setSize:CGSizeMake(menuBtnW/2, menuBtnH/2)];
    [_exitButton setZPosition:9];
    [self addChild:_exitButton];
    
    float duration = 0.5;
    [_playButton setAlpha:0];
    [_infoButton setAlpha:0];
    [_highScoreButton setAlpha:0];
    [_reviewButton setAlpha:0];
    
    [_playButton runAction:[SKAction fadeInWithDuration:duration*1] completion:^{ [_infoButton runAction:[SKAction fadeInWithDuration:duration*1] completion:^{ [_highScoreButton runAction:[SKAction fadeInWithDuration:duration*1] completion:^{ [_reviewButton runAction:[SKAction fadeInWithDuration:duration*1]];}];}];}];
}
-(void)removeMenu
{
    float duration = 0.3;
    [_playButton runAction:[SKAction fadeOutWithDuration:duration*1] completion:^{ [_infoButton runAction:[SKAction fadeOutWithDuration:duration*1] completion:^{ [_highScoreButton runAction:[SKAction fadeOutWithDuration:duration*1] completion:^{ [_reviewButton runAction:[SKAction fadeOutWithDuration:duration*1] completion:^{
            [_playButton removeFromParent];
            [_highScoreButton removeFromParent];
            [_highScoreButton removeFromParent];
            [_reviewButton removeFromParent];
    }];}];}];}];
    
    [_exitButton removeFromParent];
}

-(void)drawScore
{
    if (scoreLabel == nil)
    {
        float frameW = CGRectGetWidth(self.frame);
        float frameH = CGRectGetHeight(self.frame);
        scoreLabel =  [SKLabelNode labelNodeWithFontNamed:@"Chalkboard SE"];
        scoreLabel.fontSize = (int)(frameH / 16);
        scoreLabel.fontColor = [SKColor greenColor];
        scoreLabel.position = CGPointMake(frameW / 2, frameH - yMargin / 2 - frameH / 32);
        [self addChild:scoreLabel];
    }
    
    if (!onScoreAction)
    {
        onScoreAction = true;
        [scoreLabel runAction: [SKAction scaleBy:110.0/100 duration:0.25] completion:^{
            scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
            [scoreLabel runAction: [SKAction scaleBy:100.0/110.0 duration:0.25] completion:^{ onScoreAction = false;
            }];
        }];
    }
    
    if (nextLevelScore < score)
        [self levelUp];
}

-(void)levelUp
{
    nextLevelScore *= 2;
    levelIntervalInSeconds *= 0.8;
    bubbleRadiusDivider -= 0.1;
    bubbleRadiusDivider = MAX(0,bubbleRadiusDivider);
}

- (void)createBucket
{
    float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    
    SKSpriteNode* floor = [SKSpriteNode spriteNodeWithColor:[UIColor brownColor] size:CGSizeMake(frameW - 2 * xMargin, 5)];
    floor.position = CGPointMake(xMargin + floor.size.width/2, floor.size.height/2 + yMargin);
    floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:floor.size];
    floor.physicsBody.dynamic = NO;
    [self addChild:floor];
    
    SKSpriteNode* leftWall = [SKSpriteNode spriteNodeWithColor:[UIColor brownColor] size:CGSizeMake(5, frameH-2*yMargin)];
    leftWall.position = CGPointMake(xMargin + leftWall.size.width/2, leftWall.size.height/2 + yMargin);
    leftWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:leftWall.size];
    leftWall.physicsBody.dynamic = NO;
    [self addChild:leftWall];
    
    SKSpriteNode* rightWall = [SKSpriteNode spriteNodeWithColor:[UIColor brownColor] size:CGSizeMake(5, frameH-2*yMargin)];
    rightWall.position = CGPointMake(frameW - rightWall.size.width/2 - xMargin, leftWall.size.height/2 + yMargin);
    rightWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rightWall.size];
    rightWall.physicsBody.dynamic = NO;
    [self addChild:rightWall];
}

-(void)removeOutOfScreenBubbles
{
    float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    
    NSMutableArray* dI = [[NSMutableArray alloc] init];
    for (NumberBubble* b in bubbles) {
        if (b.position.x > frameW || b.position.y > frameH || b.position.x < 0 || b.position.y < 0)
        {
            [dI addObject:b];
        }
    }
    
    [self removeChildrenInArray:dI];
    [bubbles removeObjectsInArray:dI];
}

-(float)averageBubble
{
    float average = 0;
    float sum = 0;
    for (NumberBubble* b in bubbles) {
        sum += b.no;
    }
    average = sum/bubbles.count;
    return average;
}

-(void)addNumber
{
    if (onExplode)
        return;
    
    float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    
    float nW = frameW / ((float)arc4random_uniform(10 * bubbleRadiusDivider)/10 +bubbleRadiusMinDivider);
    
    int no=5;
    if ([self averageBubble] > 5)
        no = arc4random_uniform(5)+1;
    else
        no = arc4random_uniform(5)+5;
    
    NumberBubble* number = [NumberBubble GetNumber:no :nW];
    number.position = CGPointMake(xMargin+nW/2+arc4random_uniform(frameW-2*xMargin-nW), frameH-yMargin-nW/2);

    [self addChild:number];
    [bubbles addObject:number];
}

-(void)explodeBubbles
{
    onExplode = true;
    int sum = 0;
    bool explode = false;
    bool deselect = false;
    for (NumberBubble *b in bubbles)
    {
        if (b.isSelected)
        {
            sum += b.no;
            explode = (sum == 10);
            deselect = sum > 10;
            if (deselect)
                break;
        }
    }
    
    if (deselect)
    {
        for (NumberBubble* b in bubbles)
        {
            if (bubbles.firstObject == b) [b playWarnSound];
            [b setSelected:false];
        }
        onExplode = false;
    }
    else if (explode)
    {
        //NSMutableArray* dI = [[NSMutableArray alloc] init];
        for (NumberBubble *b in bubbles)
        {
            if (b.isSelected && !b.isRemoved)
            {
                b.isRemoved = true;
                [b playWhoopSound];
                //[dI addObject:b];
                [b runAction:[SKAction scaleBy:0.1 duration:0.5] completion:^
                 {
                     [bubbles removeObject:b];
                     [b removeFromParent];
                     onExplode = false;
                     
                     score += 0.1 * ((100.0 / b.size.width) * 10 / levelIntervalInSeconds);
                     [self drawScore];
                 }];
            }
        }
    }
    else
        onExplode=false;
}

-(void)checkGameOver
{
    //float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    
    for (NumberBubble* b in bubbles) {
        if (b.position.y>frameH - yMargin - b.size.height/2)
        {
            [self gameOver];
            return;
        }
        else if (b.position.y>frameH*0.75 - yMargin - b.size.height/2)
        {
            [b playWarnSound];
        }
    }
}

-(void)gameOver
{
    gameOver = true;
    [self createBackgroundEndMusic];
}

-(void)checkHint
{
    hintCountDown--;
    hintCountDown = MAX(0,hintCountDown);
    if (hintCountDown < 1)
    {
        [self giveHint];
    }
}
-(void)giveHint
{
    for (NumberBubble* b in bubbles) {
        for (NumberBubble* bb in bubbles) {
            if (bb.no+b.no == 10) {
                [bb setHint:true];
                [b setHint:true];
                return;
            }
        }
    }
}

-(void)startGame
{
    onMenu = false;
    gameOver = false;
    [self removeMenu];
    [self createBucket];
    [self drawScore];
    //bubbles = [[NSMutableArray alloc] init];
}


-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    [self createBackground];
    [self createBackgroundMusic];
    [self createMenu];
    bubbles = [[NSMutableArray alloc] init];
    self.physicsWorld.contactDelegate = self;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if (onMenu)
    {
        if (node == _playButton)
        {
            [self startGame];
        }
    }
    else
    {
        if ([node isKindOfClass:[NumberBubble class]])
        {
            NumberBubble* nb = (NumberBubble*)node;
            [nb click];
            hintCountDown = nextLevelScore / 20;
            [self explodeBubbles];
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (!onMenu && !gameOver && !gamePaused)
    {
        if (updatedTime == 0 || currentTime - updatedTime > levelIntervalInSeconds)
        {
            [self checkGameOver];
            [self addNumber];
            [self removeOutOfScreenBubbles];
            [self checkHint];
            updatedTime=currentTime;
        }
    }
    else if (onMenu)
    {
        if (updatedTime == 0 || currentTime - updatedTime > 0.25)
        {
            [self addNumber];
            updatedTime=currentTime;
        }
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    if ([contact.bodyA.node isKindOfClass:[NumberBubble class]])
        [((NumberBubble*)(contact.bodyA.node)) playHitSound];
    else if ([contact.bodyB.node isKindOfClass:[NumberBubble class]])
        [((NumberBubble*)(contact.bodyB.node)) playHitSound];
}

@end