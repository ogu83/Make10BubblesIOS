//
//  GameScene.m
//  Make10Bubbles
//
//  Created by Oğuz Köroğlu on 23/02/16.
//  Copyright (c) 2016 Oguz Koroglu. All rights reserved.
//

#import "Constants.h"
#import "GameScene.h"
#import "NumberBubble.h"
#import <AVFoundation/AVFoundation.h>
#import <Social/Social.h>
//#import <FacebookSDK/FacebookSDK.h>

@implementation GameScene

int xMargin = 10;
int yMargin = 70;

float bubbleRadiusMinDivider = 4;
float bubbleRadiusDivider = 6;
float levelIntervalInSeconds = 3;
CFTimeInterval updatedTime;

bool gamePaused=false;
bool gameOver=false;
bool onMenu=true;
bool onExplode=false;
bool isSoundOn = true;

NSString* UserName;
SKLabelNode* scoreLabel;
int score;
int nextLevelScore = 1;
bool onScoreAction = false;
bool hintsEnabled = true;
int hintCountDown = 5;

AVAudioPlayer *player;

NSMutableArray* bubbles;

int infoSlideMin = 4;
int infoSlideMax = 15;
int infoSlideCurrent = 4;

-(UIImage *)screenShot
{
    CGSize size = self.size;
    //CGSize size = CGSizeMake(your_width, your_height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGRect rec = CGRectMake(0, 0, size.width, size.height);
    [_viewController.view drawViewHierarchyInRect:rec afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)postTo:(NSString*)name
{
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    if ([name isEqual:@"Facebook"])
        controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    else if ([name isEqual:@"TencentWeibo"])
        controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTencentWeibo];
    else if ([name isEqual:@"SinaWeibo"])
        controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
    
    [controller setInitialText: [NSString stringWithFormat:@"Hey, I completed #%@ with score %d", GameName, score]];
    [controller addURL:[NSURL URLWithString:WebSite]];
    UIImage* img = [self screenShot];
    [controller addImage:img];
    [[self viewController] presentViewController:controller animated:YES completion:^{ }];
}

-(void)SendHighScoreToServerAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Congratulations"
                                                        message:[NSString stringWithFormat:@"Great Score: %d. Enter your name to the high score table",score]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = 124;
    [alertView show];
}
- (void)postToAlert
{
    UIAlertView * alert =[[UIAlertView alloc ]
                          initWithTitle:@"Congratulations"
                          message:[NSString stringWithFormat:@"You completed %@ with the score: %d. Do you want share the screenshot and score to your friends?", GameName, score]
                          delegate:self
                          cancelButtonTitle: @"Nope"
                          otherButtonTitles: nil];
    alert.tag = 123;
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        [alert addButtonWithTitle:@"Twitter"];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        [alert addButtonWithTitle:@"Facebook"];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTencentWeibo])
        [alert addButtonWithTitle:@"TencentWeibo"];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo])
        [alert addButtonWithTitle:@"SinaWeibo"];
    
    [alert show];
}

-(void)SendHighScoreToServer
{
    UserName = [UserName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    UIDevice *device = [UIDevice currentDevice];
    NSString  *deviceId = [[device identifierForVendor]UUIDString];
    
    NSString *post = @"";
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSString* url = [NSString stringWithFormat:@"%@/HighScore?appId=%@&deviceId=%@&name=%@&score=%d",ApiAddress,AppId,deviceId,UserName,score];
    
    //NSString* eUrl = url;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    
    NSLog([NSString stringWithFormat:@"Request URL: %@", url]);
    //NSLog([NSString stringWithFormat:@"Request EURL: %@", eUrl]);
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    //NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString* responseString =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog([NSString stringWithFormat:@"Response: %@",responseString]);
    
    if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] &&
       ![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook] &&
       ![SLComposeViewController isAvailableForServiceType:SLServiceTypeTencentWeibo] &&
       ![SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]
       )
    {
        [self gotoMenu];
    }
    else
    {
        [self postToAlert];
    }
}

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

- (void)createSoundButton:(bool)isOn
{
    //float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    float ratio = 1;
    float h = frameH / 16;
    float w = h * ratio;
    
    NSString* imageName = isOn ? @"SoundOn" : @"SoundOff";
    
    _soundButton = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    _soundButton.name = @"soundButton";
    [_soundButton setSize:CGSizeMake(w, h)];
    _soundButton.position = CGPointMake(xMargin + w, yMargin - h/2);
    [_soundButton setZPosition:1];
    [self addChild:_soundButton];
}

-(void)createPlayPauseButton:(bool)isPaused
{
    //float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    float ratio = 1;
    float h = frameH / 16;
    float w = h * ratio;
    
    NSString* imageName = isPaused ? @"PlayButton" : @"PauseButton";
    
    _playPauseButton = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    _playPauseButton.name = @"playPauseButton";
    [_playPauseButton setSize:CGSizeMake(w, h)];
    _playPauseButton.position = CGPointMake(_soundButton.size.width + 2*xMargin + w, yMargin - h/2);
    [_playPauseButton setZPosition:1];
    [self addChild:_playPauseButton];
}

-(void)createGotoMenuButton
{
    float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    float ratio = 1;
    float h = frameH / 16;
    float w = h * ratio;
    
    NSString* imageName = @"Cancel";
    
    _gotoMenuButton = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    _gotoMenuButton.name = @"gotoMenuButton";
    [_gotoMenuButton setSize:CGSizeMake(w, h)];
    _gotoMenuButton.position = CGPointMake(frameW - xMargin - w, yMargin - h/2);
    [_gotoMenuButton setZPosition:1];
    [self addChild:_gotoMenuButton];
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
    
    /*
    _exitButton = [MenuButton exitButton];
    _exitButton.position = CGPointMake(frameW-xMargin-menuBtnW/2/2,
                                    frameH-yMargin-menuBtnH/2/2);
    [_exitButton setSize:CGSizeMake(menuBtnW/2, menuBtnH/2)];
    [_exitButton setZPosition:9];
    [self addChild:_exitButton];
    */
     
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
    
    //[_exitButton removeFromParent];
}
-(void) gotoMenu
{
    [self createBackgroundMusic];
    [self createMenu];
    [self removeBucket];
    
    [_gotoMenuButton removeFromParent];
    [_soundButton removeFromParent];
    [_playPauseButton removeFromParent];
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
    
    UIColor* bucketColor = [UIColor colorWithRed:65.0/255.0 green:113.0/255.0 blue:156.0/255.0 alpha:1];
    
    SKSpriteNode* floor = [SKSpriteNode spriteNodeWithColor:bucketColor size:CGSizeMake(frameW - 2 * xMargin, 5)];
    floor.position = CGPointMake(xMargin + floor.size.width/2, floor.size.height/2 + yMargin);
    floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:floor.size];
    floor.physicsBody.dynamic = NO;
    floor.name = @"floor";
    [self addChild:floor];
    
    SKSpriteNode* leftWall = [SKSpriteNode spriteNodeWithColor:bucketColor size:CGSizeMake(5, frameH-2*yMargin)];
    leftWall.position = CGPointMake(xMargin + leftWall.size.width/2, leftWall.size.height/2 + yMargin);
    leftWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:leftWall.size];
    leftWall.physicsBody.dynamic = NO;
    leftWall.name = @"leftwall";
    [self addChild:leftWall];
    
    SKSpriteNode* rightWall = [SKSpriteNode spriteNodeWithColor:bucketColor size:CGSizeMake(5, frameH-2*yMargin)];
    rightWall.position = CGPointMake(frameW - rightWall.size.width/2 - xMargin, leftWall.size.height/2 + yMargin);
    rightWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rightWall.size];
    rightWall.physicsBody.dynamic = NO;
    rightWall.name = @"rightwall";
    [self addChild:rightWall];
}
-(void)removeBucket
{
    [[self childNodeWithName:@"floor"] removeFromParent];
    [[self childNodeWithName:@"leftwall"] removeFromParent];
    [[self childNodeWithName:@"rightwall"] removeFromParent];
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
    [self SendHighScoreToServerAlert];
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
    int makeWhat = 10;
    for (NumberBubble* b in bubbles) {
        for (NumberBubble* bb in bubbles) {
            if (bb == b) continue;
            if (bb.no+b.no == makeWhat) {
                [bb setHint:true];
                [b setHint:true];
                return;
            }
            for (NumberBubble* bbb in bubbles) {
                if (bbb == bb || bbb == b) continue;
                if (bbb.no+bb.no+b.no == makeWhat) {
                    [bbb setHint:true];
                    [bb setHint:true];
                    [b setHint:true];
                    return;
                }
                for (NumberBubble* bbbb in bubbles) {
                    if (bbbb == bbb || bbbb == bb || bbbb == b) continue;
                    if (bbbb.no+bbb.no+bb.no+b.no == makeWhat) {
                        [bbbb setHint:true];
                        [bbb setHint:true];
                        [bb setHint:true];
                        [b setHint:true];
                        return;
                    }
                }
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

    [self createSoundButton:isSoundOn];
    [self createPlayPauseButton:gamePaused];
    [self createGotoMenuButton];
    //bubbles = [[NSMutableArray alloc] init];
    
    bubbleRadiusMinDivider = 4;
    bubbleRadiusDivider = 6;
    levelIntervalInSeconds = 3;
    score=0;
    nextLevelScore = 100;
    onScoreAction = false;
    hintsEnabled = true;
    hintCountDown = 5;
}


-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    [self createBackground];
    [self createBackgroundMusic];
    [self createMenu];
    bubbles = [[NSMutableArray alloc] init];
    self.physicsWorld.contactDelegate = self;
    
    float frameW = CGRectGetWidth(self.frame);
    float frameH = CGRectGetHeight(self.frame);
    yMargin = frameH / 16;
    xMargin = frameW / 18;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99)
    {
        if (buttonIndex != 0)  // 0 == the cancel button
        {
            //home button press programmatically
            UIApplication *app = [UIApplication sharedApplication];
            [app performSelector:@selector(suspend)];
            //wait 2 seconds while app is going background
            [NSThread sleepForTimeInterval:2.0];
            //exit app when app is in background
            exit(0);
        }
    }
    else if (alertView.tag == 98)
    {
        if (buttonIndex != 0)  // 0 == the cancel button
            [self gameOver];
        else
        {
            gamePaused = NO;
            if (isSoundOn)
                [player play];
        }
    }
    else if (alertView.tag == 123)
    {
        if (buttonIndex == 0)  // 0 == the cancel button
        {
            
        }
        else
        {
            NSString* btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
            [self postTo:btnTitle];
        }
        
        [self gotoMenu];
    }
    else if (alertView.tag == 124)
    {
        if (buttonIndex == 0)  // 0 == the cancel button
        {
            [self postToAlert];
        }
        else
        {
            UserName = [alertView textFieldAtIndex:0].text;
            [self SendHighScoreToServer];
        }
    }
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
        else if (node == _exitButton)
        {
            [self doExit];
            return;
        }
        else if (node == _reviewButton)
        {
            NSString* itunesLink=[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8",AppId];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: itunesLink]];
            return;
        }
        else if (node == _highScoreButton)
        {
            NSString* link=[NSString stringWithFormat:@"%@/HighScore",WebSite];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: link]];
            return;
        }
        else if (node == _infoButton)
        {
            float frameW = CGRectGetWidth(self.frame);
            float frameH = CGRectGetHeight(self.frame);
            infoSlideCurrent = infoSlideMin;
            _infoScreen = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"Slide%d",infoSlideCurrent]];
            _infoScreen.position = CGPointMake(frameW/2, frameH/2);
            _infoScreen.size = CGSizeMake(frameW, frameH);
            [_infoScreen setZPosition:99];
            [self addChild:_infoScreen];
            return;
        }
        else if (node == _infoScreen)
        {
            infoSlideCurrent++;
            if (infoSlideCurrent<=infoSlideMax)
            {
                SKAction* changeSlideAction = [SKAction setTexture:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"Slide%d",infoSlideCurrent]]];
                [_infoScreen runAction:changeSlideAction];
            }
            else
            {
                [_infoScreen removeFromParent];
                _infoScreen = nil;
            }
        }
    }
    else
    {
        if ([node.name isEqualToString:@"soundButton"])
        {
            isSoundOn = !isSoundOn;
            if (!isSoundOn)
                [player stop];
            else
                [self createBackgroundMusic];
            
            [node removeFromParent];
            [self createSoundButton:isSoundOn];
            return;
        }
        else if ([node.name isEqualToString:@"playPauseButton"])
        {
            gamePaused = !gamePaused;
            if (gamePaused)
                [player stop];
            else if (isSoundOn)
                [player play];
            
            [node removeFromParent];
            [self createPlayPauseButton:gamePaused];
            return;
        }
        else if ([node.name isEqualToString:@"gotoMenuButton"])
        {
            gamePaused = YES;
            [player stop];
            
            //show confirmation message to user
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"End Game"
                                                            message:@"Are you leaving?"
                                                           delegate:self
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes", nil];
            alert.tag = 98;
            [alert show];
            
            return;
        }
        
        if (!gamePaused && !gameOver) {
            if ([node isKindOfClass:[NumberBubble class]]) {
                NumberBubble* nb = (NumberBubble*)node;
                [nb click];
                hintCountDown = nextLevelScore / 20;
                [self explodeBubbles];
            }
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
            if (_infoScreen == nil)
                [self addNumber];
            [self removeOutOfScreenBubbles];
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

-(IBAction)doExit
{
    //show confirmation message to user
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Exit"
                                                    message:@"Are you leaving?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    alert.tag = 99;
    [alert show];
}

@end