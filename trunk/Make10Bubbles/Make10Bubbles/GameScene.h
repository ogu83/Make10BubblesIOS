//
//  GameScene.h
//  Make10Bubbles
//

//  Copyright (c) 2016 Oguz Koroglu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameViewController.h"
#import "MenuButton.h"

@interface GameScene : SKScene

@property GameViewController* viewController;

@property MenuButton* playButton;
@property MenuButton* infoButton;
@property MenuButton* highScoreButton;
@property MenuButton* reviewButton;
@property MenuButton* closeButton;
@property MenuButton* exitButton;

@end
