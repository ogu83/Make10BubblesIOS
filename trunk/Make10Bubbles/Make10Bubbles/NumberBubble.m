//
//  Number.m
//  Make10Bubbles
//
//  Created by Oğuz Köroğlu on 23/02/16.
//  Copyright © 2016 Oguz Koroglu. All rights reserved.
//

#import "NumberBubble.h"

@implementation NumberBubble

+(id)GetNumber:(int)no :(float)radius
{
    NumberBubble *n = [NumberBubble spriteNodeWithImageNamed:@(no).stringValue];
    n.no = no;
    n.size = CGSizeMake(radius, radius);
    n.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius/2];
    n.physicsBody.mass = 1;
    n.physicsBody.restitution=0.5;
    return n;
}

-(void) setSelected :(BOOL)isSelected
{
    _isSelected=isSelected;
    self.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%d%s",_no,_isSelected?"S":""]];
}

-(void) click
{
    [self setSelected:!_isSelected];
}

@end
