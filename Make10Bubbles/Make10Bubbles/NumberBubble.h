//
//  Number.h
//  Make10Bubbles
//
//  Created by Oğuz Köroğlu on 23/02/16.
//  Copyright © 2016 Oguz Koroglu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface NumberBubble : SKSpriteNode

+(id)GetNumber:(int)no :(float)radius;

@property int no;
@property bool isSelected;
@property bool isRemoved;
@property bool isHint;

@property (strong, nonatomic) SKAction *hitSound;
@property (strong, nonatomic) SKAction *whoopSound;
@property (strong, nonatomic) SKAction *warnSound;
@property (strong, nonatomic) SKAction *clickSound;

-(void) setHint :(BOOL)on;
-(void) setSelected :(BOOL)isSelected;
-(void) click;
-(void) playClickSound;
-(void) playHitSound;
-(void) playWhoopSound;
-(void) playWarnSound;

@end
