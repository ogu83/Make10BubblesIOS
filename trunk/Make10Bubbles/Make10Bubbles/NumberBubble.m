//
//  Number.m
//  Make10Bubbles
//
//  Created by Oğuz Köroğlu on 23/02/16.
//  Copyright © 2016 Oguz Koroglu. All rights reserved.
//

#import "NumberBubble.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation NumberBubble

static float defaultMass = 1;
static float defaultBouncy = 0.5;
static bool isClickSoundPlaying;
static bool isHitSoundPlaying;
static bool isWhoopSoundPlaying;
static bool isWarnSoundPlaying;

+(id)GetNumber:(int)no :(float)radius
{
    NumberBubble *n = [NumberBubble spriteNodeWithImageNamed:@(no).stringValue];
    n.no = no;
    n.isSelected = false;
    n.size = CGSizeMake(radius, radius);
    n.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius/2];
    n.physicsBody.mass = defaultMass;
    n.physicsBody.restitution = defaultBouncy;
    n.physicsBody.friction = 0.1;
    n.physicsBody.usesPreciseCollisionDetection = true;
    n.physicsBody.categoryBitMask = 1;
    n.physicsBody.contactTestBitMask = 1;
    n.physicsBody.collisionBitMask = 1;
    return n;
}

-(void) setSelected :(BOOL)isSelected
{
    _isSelected = isSelected;
    self.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%d%s",_no,_isSelected?"S":""]];
}

-(void) click
{
    [self setSelected:!_isSelected];
    [self playClickSound];
}

- (void)playClickSound
{
    if (!isClickSoundPlaying)
    {
        SKAction *soundAction = [SKAction playSoundFileNamed:@"button-3_GSM.wav" waitForCompletion:YES];
        //play once
        isClickSoundPlaying = true;
        [self runAction:soundAction completion:^{ isClickSoundPlaying =false; }];
        //play and repeat forever
        //[self runAction:[SKAction repeatActionForever:soundAction]];
    }
}

-(void)playHitSound
{
    if (isHitSoundPlaying)
        return;
        
    if (self.physicsBody.contactTestBitMask == 0)
        return;
    
    self.physicsBody.contactTestBitMask = 0;
    
    SKAction *soundAction = [SKAction playSoundFileNamed:@"drop-ball-in-cup-2_GSM.wav" waitForCompletion:YES];
    
    isHitSoundPlaying = true;
    [self runAction:soundAction completion:^{ isHitSoundPlaying = false; }];
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

-(void)playWhoopSound
{
    if (isWhoopSoundPlaying)
        return;
    
    SKAction *soundAction = [SKAction playSoundFileNamed:@"slow-whoop-bubble-pop1_GSM.wav" waitForCompletion:YES];
    
    isWhoopSoundPlaying = true;
    [self runAction:soundAction completion:^{ isWhoopSoundPlaying = false; }];
}

-(void)playWarnSound
{
    if (isWarnSoundPlaying)
        return;
    
    SKAction *soundAction = [SKAction playSoundFileNamed:@"catspaw64_warning-signal_GSM.wav" waitForCompletion:YES];
    
    isWarnSoundPlaying = true;
    [self runAction:soundAction completion:^{ isWarnSoundPlaying = false; }];
}

@end
