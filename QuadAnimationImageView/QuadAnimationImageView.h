/*
 
 QuadAnimationImageView.h
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

#import <Foundation/Foundation.h>

/* 
 Animatin blocks take the CALayer of the quad piece, and the x/y location of the quad
 inside view.
 
 The return float is the time the animation should be allowed before the outgoing quad is removed
 from the layer hierarchy (and then destroyed)
 */
typedef float (^QuadAnimationBlock)(CALayer *quadLayer, int x, int y);


@interface QuadAnimationImageView : UIView {
	NSMutableArray *_imageArray;
}

/* The number of quads in the X and Y axes.  These must be set at initialization */
@property (nonatomic, readonly) int quadsX;
@property (nonatomic, readonly) int quadsY;

/* 
 If YES, the quads of the new image will be inserted above the existing quads in the layer hierarchy.
 If NO, the quads of the new image will be inserted below.  Default is NO.
 */
@property (nonatomic) BOOL newQuadsAbove;

/*
 How much time (in seconds) should be given to old quad layers before they 
 are removed (if no outgoing animation is specified).
 
 Default is 1 second.
 */
@property (nonatomic) float oldQuadLifetime;

/* Initialize in frame with given number of quads in the X and Y axes. */
- (id) initWithFrame:(CGRect)frame withQuadsX:(int)quadsX quadsY:(int)quadsY;

/* 
 This is the main animation function.
 image - the new image to display.  The image will be sized to fit in the view's frame.
 quadAnimationIn - the animation that will be applied to each quad of the incoming image.
 quadAnimationOut - the animation that will be applied to each quad of the outgoing image.
 */
- (void) animateToImage:(UIImage*)image withQuadAnimationIn:(QuadAnimationBlock)quadAnimationIn animationOut:(QuadAnimationBlock)quadAnimationOut;

/*
 An example implementation in which the view turns into the new image via a left-to-right shimmer effect.
 */
- (void) leftRightShimmerToImage:(UIImage*)image;


@end

