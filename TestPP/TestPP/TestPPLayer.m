//
//  TestPPLayer.m
//  TestPP
//
//  Created by Yongmo Liang on 8/9/13.
//  Copyright 2013 rockyee. All rights reserved.
//

#import "TestPPLayer.h"

@interface TestPPLayer() {
    CCRenderTexture *_rt;
    
    CCSprite *test1;
    CCSprite *test2;
    
    bool isDraggingTest1;
}

@end

@implementation TestPPLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TestPPLayer *layer = [TestPPLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
    if( (self=[super init]) ) {
        
        ccColor4B color = {245, 236, 206, 255};
        CCLayerColor *cloerLayer = [CCLayerColor layerWithColor:color];
        [self addChild:cloerLayer z:0];
        
        self.touchEnabled = YES;
        test1 = [CCSprite spriteWithFile:@"acc01.png"];
        test1.position = ccp(100, 100);
        test1.scale = 0.5f;
        test1.opacity = 100;
        [self addChild:test1 z:2];
        test2 = [CCSprite spriteWithFile:@"acc02.png"];
        test2.position = ccp (300, 200);
        test2.scale = 0.5f;
        test2.rotation = 90.0f;
        [self addChild:test2 z:2];
    }
    
    return self;
}


-(BOOL) isCollisionBetweenSpriteA:(CCSprite*)spr1 spriteB:(CCSprite*)spr2 pixelPerfect:(BOOL)pp
{
    BOOL isCollision = NO;
    CGRect intersection = CGRectIntersection([spr1 boundingBox], [spr2 boundingBox]);
    
    // Look for simple bounding box collision
    if (!CGRectIsEmpty(intersection))
    {
        // If we're not checking for pixel perfect collisions, return true
        if (!pp) {return YES;}
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        _rt = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];
        _rt.position = CGPointMake(winSize.width/2, winSize.height/2);
        [self addChild:_rt z:1];
        
        // Get intersection info
        unsigned int x = intersection.origin.x *CC_CONTENT_SCALE_FACTOR();
        unsigned int y = intersection.origin.y *CC_CONTENT_SCALE_FACTOR();
        unsigned int w = intersection.size.width *CC_CONTENT_SCALE_FACTOR();
        unsigned int h = intersection.size.height *CC_CONTENT_SCALE_FACTOR();
        unsigned int numPixels = w * h;
        
        // Draw into the RenderTexture
        [_rt beginWithClear:0 g:0 b:0 a:0];
        
        // Render both sprites: first one in RED and second one in GREEN
        glColorMask(1, 0, 0, 1);
        [spr1 visit];
        glColorMask(0, 1, 0, 1);
        [spr2 visit];
        glColorMask(1, 1, 1, 1);
        
        // Read pixels
        ccColor4B *buffer = malloc( sizeof(ccColor4B) * numPixels );
        glReadPixels(x, y, w, h, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
        
        [_rt end];
        
        // Read buffer
        unsigned int step = 1;
        for(unsigned int i=0; i<numPixels; i+=step)
        {
            ccColor4B color = buffer[i];
            
            if (color.r > 0 && color.g > 0)
            {
                isCollision = YES;
                break;
            }
        }
        
        // Free buffer memory
        free(buffer);
        [_rt removeFromParentAndCleanup:YES];
    }
    
    return isCollision;
}

-(void) registerWithTouchDispatcher
{
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint posUI = [touch locationInView:[touch view]];
    CGPoint pos = [[CCDirector sharedDirector] convertToGL:posUI];
    
    if (CGRectContainsPoint([test1 boundingBox], pos)) {
        isDraggingTest1 = YES;
    }
 
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint posUI = [touch locationInView:[touch view]];
    CGPoint pos = [[CCDirector sharedDirector] convertToGL:posUI];
    
    CGPoint prev = [touch previousLocationInView:[touch view]];
    prev = [[CCDirector sharedDirector] convertToGL:prev];
    if (isDraggingTest1) {
        [test1 setPosition:ccpAdd(test1.position, ccpSub(pos, prev))];
        if ([self isCollisionBetweenSpriteA:test1 spriteB:test2 pixelPerfect:YES]) {
            test1.color = ccGREEN;
            test2.color = ccRED;
        } else {
            test1.color = ccWHITE;
            test2.color = ccWHITE;
        }
    }

	
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{

	
}

@end
