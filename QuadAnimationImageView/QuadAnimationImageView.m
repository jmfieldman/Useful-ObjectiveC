/*
 
 QuadAnimationImageView.m
 Copyright (C) 2012 Jason Fieldman
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the "Software"),
 to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included
 in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "QuadAnimationImageView.h"

@implementation QuadAnimationImageView

/* Set default X/Y sizing if none are specified */
- (id) initWithFrame:(CGRect)frame {
	return [self initWithFrame:frame withQuadsX:8 quadsY:8];
}

/* Initialize the view with the given number of quads in the X and Y axes. */
- (id) initWithFrame:(CGRect)frame withQuadsX:(int)quadsX quadsY:(int)quadsY {
	if ((self = [super initWithFrame:frame])) {
		_imageArray = [NSMutableArray array];
		
		_quadsX = quadsX;
		_quadsY = quadsY;
		
		_oldQuadLifetime = 1;
	}
	return self;
}


/*
 This is the main animation function.
 image - the new image to display.  The image will be sized to fit in the view's frame.
 quadAnimationIn - the animation that will be applied to each quad of the incoming image.
 quadAnimationOut - the animation that will be applied to each quad of the outgoing image.
 */
- (void) animateToImage:(UIImage*)image withQuadAnimationIn:(QuadAnimationBlock)quadAnimationIn animationOut:(QuadAnimationBlock)quadAnimationOut {
	
	/* Determine metrics for the quad sizing */
	float imageChunkWidth  = image.size.width  / _quadsX;
	float imageChunkHeight = image.size.height / _quadsY;
	float viewChunkWidth   = self.frame.size.width  / _quadsX;
	float viewChunkHeight  = self.frame.size.height / _quadsY;
	
	/* Get the CGImageRef of the incoming image */
	CGImageRef imgCG = image.CGImage;
	
	/* Blip the old layers into a temporary array */
	NSArray *oldTiles = [NSArray arrayWithArray:_imageArray];
	
	/* Clear out the quad layer cache */
	[_imageArray removeAllObjects];
	
	/* Index into our old layer array */
	int oldIndex = 0;
	
	/* Iterate through each quad.. */
	for (int y = 0; y < _quadsY; y++) {
		for (int x = 0; x < _quadsX; x++) {
			
			/* Get the old layer (if it exists) */
			CALayer *oldLayer = nil;
			if (oldIndex < [oldTiles count]) {
				oldLayer = [oldTiles objectAtIndex:oldIndex];
				if (quadAnimationOut) {
					/* And perform our outgoing animation on it */
					float removeAfter = quadAnimationOut(oldLayer, x, y);
					[oldLayer performSelector:@selector(removeFromSuperlayer) withObject:nil afterDelay:removeAfter];
				} else {
					/* Without an outgoing animation, the quad layer is removed in the default time */
					[oldLayer performSelector:@selector(removeFromSuperlayer) withObject:nil afterDelay:_oldQuadLifetime];
				}
				oldIndex++;
			}
			
			/* Get the chunk of image that should be placed in this quad */
			float scale = image.scale;
			CGRect imageChunkRect = CGRectMake(x * imageChunkWidth * scale, y * imageChunkHeight * scale, imageChunkWidth * scale, imageChunkHeight * scale);
			CGImageRef chunkImage = CGImageCreateWithImageInRect(imgCG, imageChunkRect);
			
			/* Create a new CALayer object for this quad */
			CALayer *newImageChunk = [[CALayer alloc] init];
			newImageChunk.frame = CGRectMake(x * viewChunkWidth, y * viewChunkHeight, viewChunkWidth, viewChunkHeight);;
			newImageChunk.contents = (__bridge id)chunkImage;
			CGImageRelease(chunkImage);
			
			/* Insert the new quad in the appropriate place in the hierarchy */
			if (oldLayer) {
				if (_newQuadsAbove) {
					[self.layer insertSublayer:newImageChunk above:oldLayer];
				} else {
					[self.layer insertSublayer:newImageChunk below:oldLayer];
				}
			} else {
				[self.layer addSublayer:newImageChunk];
			}
			
			/* Animate the incoming quad if necessary */
			if (quadAnimationIn) {
				quadAnimationIn(newImageChunk, x, y);
			}
			
			/* Add the new quad to the layer array */
			[_imageArray addObject:newImageChunk];
			
		}
	}
}


/* 
 The example implementation creates a left-to-right shimmer effect.
 
 The new quads are placed under the old ones.  The old quads are then faded out in sequence from left-to-right
 with a random jitter.
 */
- (void) leftRightShimmerToImage:(UIImage*)image {
	
	/* New quads should come in below the old ones */
	_newQuadsAbove = NO;
	
	QuadAnimationBlock animOut = ^ float (CALayer *quadLayer, int x, int y) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
		animation.toValue = [NSNumber numberWithFloat:0];
		animation.duration = 0.5;
		animation.beginTime = CACurrentMediaTime() + (x * 0.0625) + (0.21 * (rand()&0xFFFF)/65535.0);
		animation.fillMode = kCAFillModeForwards;
		animation.removedOnCompletion = NO;
		[quadLayer addAnimation:animation forKey:nil];
		return 2;
	};
		
	[self animateToImage:image withQuadAnimationIn:nil animationOut:animOut];
}



@end
