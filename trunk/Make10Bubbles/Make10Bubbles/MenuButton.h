//
//  MenuButton.h
//  Make10Bubbles
//
//  Created by Oğuz Köroğlu on 23/02/16.
//  Copyright © 2016 Oguz Koroglu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MenuButton : SKSpriteNode

+(id)playButton;
+(id)infoButton;
+(id)highScoreButton;
+(id)reviewButton;
+(id)exitButton;

+(float)buttonScaleRatio;

@end
