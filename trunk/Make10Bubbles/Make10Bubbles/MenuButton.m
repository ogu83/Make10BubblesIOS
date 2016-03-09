//
//  MenuButton.m
//  Make10Bubbles
//
//  Created by Oğuz Köroğlu on 23/02/16.
//  Copyright © 2016 Oguz Koroglu. All rights reserved.
//

#import "MenuButton.h"

@implementation MenuButton

+(id)playButton
{
    MenuButton *b = [MenuButton spriteNodeWithImageNamed:@"PlayButton"];
    b.name = @"PlayButton";
    return b;
}
+(id)infoButton
{
    MenuButton *b = [MenuButton spriteNodeWithImageNamed:@"InfoButton"];
    b.name = @"InfoButton";
    return b;
}
+(id)highScoreButton
{
    MenuButton *b = [MenuButton spriteNodeWithImageNamed:@"HighScoreButton"];
    b.name = @"HighScoreButton";
    return b;
}
+(id)reviewButton
{
    MenuButton *b = [MenuButton spriteNodeWithImageNamed:@"ReviewButton"];
    b.name = @"ReviewButton";
    return b;
}
+(id)exitButton
{
    MenuButton *b = [MenuButton spriteNodeWithImageNamed:@"CloseButton"];
    b.name = @"ExitButton";
    return b;
}
+(id)twitterButton
{
    MenuButton *b = [MenuButton spriteNodeWithImageNamed:@"twitter_square-512"];
    b.name = @"TwitterButton";
    return b;
}
+(id)facebookButton
{
    MenuButton *b = [MenuButton spriteNodeWithImageNamed:@"square-facebook-512"];
    b.name = @"FacebookButton";
    return b;
}

+(float)buttonScaleRatio
{
    return 1.0 / 1.0;
}

@end
