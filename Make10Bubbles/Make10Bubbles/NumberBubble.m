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

float defaultMass = 1;
float defaultBouncy = 0.5;

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
    SKAction *soundAction = [SKAction playSoundFileNamed:@"button-3_GSM.wav" waitForCompletion:NO];
    //play once
    [self runAction:soundAction];
    //play and repeat forever
    //[self runAction:[SKAction repeatActionForever:soundAction]];
}

-(void)playHitSound
{
    self.physicsBody.contactTestBitMask=0;
    SKAction *soundAction = [SKAction playSoundFileNamed:@"drop-ball-in-cup-2_GSM.wav" waitForCompletion:NO];
    //play once
    [self runAction:soundAction];
    //play and repeat forever
    //[self runAction:[SKAction repeatActionForever:soundAction]];
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
