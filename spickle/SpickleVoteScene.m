//
//  GameScene.m
//  spickle
//
//  Created by Joel Seligstein on 10/10/14.
//  Copyright (c) 2014 Joel Seligstein. All rights reserved.
//

#import "SpickleVoteScene.h"

@interface SpickleVoteScene()

@property (nonatomic, retain) SKSpriteNode *logo;
@property (nonatomic, retain) SKSpriteNode *cameraIcon;
@property (nonatomic, retain) SKSpriteNode *homeIcon;
@property (nonatomic, retain) SKSpriteNode *gearIcon;

@property (nonatomic) unsigned int curImage;
@property (nonatomic, retain) NSArray *topImages;
@property (nonatomic, retain) NSArray *botImages;
@property (nonatomic, retain) NSArray *promptStrings;

@property (nonatomic, retain) SKCropNode *curTop;
@property (nonatomic, retain) SKCropNode *curBot;
@property (nonatomic, retain) SKCropNode *nextTop;
@property (nonatomic, retain) SKCropNode *nextBot;

@property (nonatomic, retain) SKLabelNode *curPrompt;
@property (nonatomic, retain) SKLabelNode *nextPrompt;
@property (nonatomic, retain) SKSpriteNode *curPromptBg;
@property (nonatomic, retain) SKSpriteNode *nextPromptBg;

@end

@implementation SpickleVoteScene


- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    NSLog(@"Size: %@", NSStringFromCGSize(size));

    [self setBackgroundColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:0]];
    
    self.logo = [SKSpriteNode spriteNodeWithImageNamed:@"Pickle Logo"];
    self.logo.xScale = .25;
    self.logo.yScale = .25;
    self.logo.position = CGPointMake(size.width-self.logo.size.width+10, self.logo.size.height/2+10);
    self.logo.zPosition = 1;
    [self addChild:self.logo];
    
    self.cameraIcon = [SKSpriteNode spriteNodeWithImageNamed:@"camera32_inverted"];
    self.cameraIcon.position = CGPointMake(25, self.cameraIcon.size.height/2+7);
    self.cameraIcon.zPosition = 1;
    [self addChild:self.cameraIcon];

    self.homeIcon = [SKSpriteNode spriteNodeWithImageNamed:@"home32_inverted"];
    self.homeIcon.position = CGPointMake(25, size.height-self.cameraIcon.size.height+7);
    self.homeIcon.zPosition = 1;
    [self addChild:self.homeIcon];

    self.gearIcon = [SKSpriteNode spriteNodeWithImageNamed:@"gear32_inverted"];
    self.gearIcon.position = CGPointMake(size.width-self.gearIcon.size.width+10, size.height-self.gearIcon.size.height+7);
    self.gearIcon.zPosition = 1;
    [self addChild:self.gearIcon];
    
    self.curImage = 0;
    self.topImages = @[@"braid1", @"cat1", @"friends1"];
    self.botImages = @[@"braid2", @"cat2", @"friends2"];
    self.promptStrings = @[@"Best braid?", @"Ugliest cat?", @"Funniest Friends Character?"];
    
    [self loadNext];
    
    return self;
    
}

- (void)loadNext {
    [self loadNext:YES];
}

- (void)loadNext:(BOOL)topGoesLeft {
    float duration = .5;
    self.curImage = (self.curImage + 1) % self.topImages.count;
    CGSize halfScreenSize = CGSizeMake(self.size.width, self.size.height / 2);
    
    
    
    
    // top image
    SKSpriteNode *loadedTop = [SKSpriteNode spriteNodeWithImageNamed:[self.topImages objectAtIndex:self.curImage]];
    SKSpriteNode *maskTop = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:halfScreenSize];
    self.nextTop = [SKCropNode node];
    [self.nextTop setMaskNode:maskTop];
    [self.nextTop setUserInteractionEnabled:NO];
    [loadedTop setName:@"top"];
    [self.nextTop addChild:loadedTop];
    
    CGPoint startingTop = topGoesLeft
        ? CGPointMake(self.size.width*1.5, self.size.height * .75)
        : CGPointMake(-self.size.width*1.5, self.size.height * .75);
    CGPoint endingTop = CGPointMake(self.size.width / 2, self.size.height * .75);
    
    [self.nextTop setPosition:startingTop];
    [self addChild:self.nextTop];

    SKAction *nextMoveTop = [SKAction moveTo:endingTop duration:duration];
  
    // bottom image
    SKSpriteNode *loadedBot = [SKSpriteNode spriteNodeWithImageNamed:[self.botImages objectAtIndex:self.curImage]];
    SKSpriteNode *maskBot = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:halfScreenSize];
    self.nextBot = [SKCropNode node];
    [self.nextBot setMaskNode:maskBot];
    [self.nextBot setUserInteractionEnabled:NO];
    [loadedBot setName:@"bottom"];
    [self.nextBot addChild:loadedBot];

    CGPoint startingBot = topGoesLeft
        ? CGPointMake(-self.size.width*1.5, self.size.height * .25)
        : CGPointMake(self.size.width*1.5, self.size.height * .25);
    CGPoint endingBot = CGPointMake(self.size.width / 2, self.size.height * .25);
    
    [self.nextBot setPosition:startingBot];
    [self addChild:self.nextBot];
    
    SKAction *nextMoveBot = [SKAction moveTo:endingBot duration:duration];
    
    // new prompt (fade in)
    self.nextPrompt = [SKLabelNode labelNodeWithFontNamed:@"AmericanTypewriter"];
    self.nextPrompt.text = [self.promptStrings objectAtIndex:self.curImage];
    self.nextPrompt.fontSize = 26;

    self.nextPromptBg = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.75] size:CGSizeMake(self.size.width, self.nextPrompt.fontSize+10)];
    self.nextPromptBg.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self.nextPromptBg addChild:self.nextPrompt];
    self.nextPrompt.position = CGPointMake(0, -CGRectGetMidY(self.nextPrompt.frame));
    [self addChild:self.nextPromptBg];
    SKAction *nextPromptFade = [SKAction fadeInWithDuration:duration/2.0];
    
    if (self.curTop) {
        __block NSUInteger curCounter = 0;
        void (^curSyncBlock)(void) = ^{
            curCounter++;
            if (curCounter == 6) {
                [self.curTop removeFromParent];
                self.curTop = self.nextTop;
                [self.curBot removeFromParent];
                self.curBot = self.nextBot;

                [self.curPromptBg removeFromParent];
                self.curPrompt = self.nextPrompt;
                self.curPromptBg = self.nextPromptBg;
            }
        };
        
        CGPoint curEndingTop = topGoesLeft
            ? CGPointMake(-self.size.width*1.5, self.size.height*.75)
            : CGPointMake(self.size.width*1.5, self.size.height*.75);
        CGPoint curEndingBot = topGoesLeft
            ? CGPointMake(self.size.width*1.5, self.size.height*.25)
            : CGPointMake(-self.size.width*1.5, self.size.height*.25);
        
        SKAction *curMoveTop = [SKAction moveTo:curEndingTop duration:duration];
        SKAction *curMoveBot = [SKAction moveTo:curEndingBot duration:duration];
        SKAction *curPromptFade = [SKAction fadeOutWithDuration:duration/2.0];
        
        [self.curTop runAction:curMoveTop completion:curSyncBlock];
        [self.curBot runAction:curMoveBot completion:curSyncBlock];
        [self.nextTop runAction:nextMoveTop completion:curSyncBlock];
        [self.nextBot runAction:nextMoveBot completion:curSyncBlock];
        [self.curPrompt runAction:curPromptFade completion:curSyncBlock];
        [self.nextPrompt runAction:nextPromptFade completion:curSyncBlock];
    } else {
        
        __block NSUInteger nextCounter = 0;
        void (^nextSyncBlock)(void) = ^{
            nextCounter++;
            if (nextCounter == 3) {
                self.curTop = self.nextTop;
                self.curBot = self.nextBot;
                self.curPrompt = self.nextPrompt;
                self.curPromptBg = self.nextPromptBg;
            }
        };
        
        [self.nextTop runAction:nextMoveTop completion:nextSyncBlock];
        [self.nextBot runAction:nextMoveBot completion:nextSyncBlock];
        [self.nextPrompt runAction:nextPromptFade completion:nextSyncBlock];
    }

}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];

    if ([node.name isEqualToString:@"top"]) {
        [self loadNext:NO];
    } else if ([node.name isEqualToString:@"bottom"]) {
        [self loadNext:YES];
    }
}


@end
