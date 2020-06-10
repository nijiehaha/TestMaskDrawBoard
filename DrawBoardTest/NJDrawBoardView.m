#import "NJDrawBoardView.h"

@interface NJDrawBoardView()

{
    
    PainterContent *_content;
    
    NSMutableArray <UIBezierPath *> *_pathArray;
    
    UIImage *_maskImage;
    
    UIImage *_backImage;
    
    UIImage *_originImage;
    
}

// 遮罩
@property (nonatomic, strong) UIImageView *maskImageView;

// 中间
@property (nonatomic, strong) UIImageView *centerImageView;

@end

@implementation NJDrawBoardView

- (instancetype)initWithFrame:(CGRect)frame originImage:(UIImage *)originImage maskImage:(UIImage *)maskImage back:(UIImage *)back
{
    
    if (self = [super initWithFrame:frame]) {
                
        self.image = originImage;
        self.userInteractionEnabled = YES;
        _paintColor = [UIColor blackColor];
        _paintWidth = 10;
        _pathArray = [[NSMutableArray alloc] initWithCapacity:0];
        
//        self.centerImageView.image = clearImage;
        
        CGImageRef maskRef = maskImage.CGImage;
        CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                            CGImageGetHeight(maskRef),
                                            CGImageGetBitsPerComponent(maskRef),
                                            CGImageGetBitsPerPixel(maskRef),
                                            CGImageGetBytesPerRow(maskRef),
                                            CGImageGetDataProvider(maskRef), nil, YES);
        
        self.maskImageView.image = [UIImage imageWithCGImage:mask];
        _maskImage = maskImage;
        _backImage = back;
        _originImage = originImage;
        
    }
    
    return self;
    
}

- (UIImageView *)centerImageView
{
    
    if (_centerImageView == nil) {
        
        _centerImageView = [[UIImageView alloc] initWithFrame:self.bounds];
//        [self addSubview:_centerImageView];
        
    }
    
    return _centerImageView;
    
}

- (UIImageView *)maskImageView
{
    
    if (_maskImageView == nil) {
        
        _maskImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_maskImageView];
        
    }
    
    return _maskImageView;
    
}

// 开始画
- (void)beginDraw:(CGRect)rect
{
    
    UIImage *maskImage = [self drawMask:rect];
    
    CGImageRef maskRef = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), nil, YES);
    
    CGImageRef resultMaskImage =  CGImageCreateWithMask(_backImage.CGImage, mask);
    
//    UIImage *res = [self getImage:_originImage mask:maskImage];
    
//    CGImageRef maskRef = maskImage.CGImage;
//    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
//                                        CGImageGetHeight(maskRef),
//                                        CGImageGetBitsPerComponent(maskRef),
//                                        CGImageGetBitsPerPixel(maskRef),
//                                        CGImageGetBytesPerRow(maskRef),
//                                        CGImageGetDataProvider(maskRef), nil, YES);
//    CGImageRef resultMaskImage =  CGImageCreateWithMask(_backImage.CGImage, mask);
    
    self.maskImageView.image = [UIImage imageWithCGImage:resultMaskImage];
    
}

- (UIImage *)drawMask:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 1.0);
    
    [_maskImage drawInRect:self.frame];
    
    if (_content.color == [UIColor clearColor]) {
        //        [[UIColor clearColor] setStroke];
        //        CGContextSetBlendMode(context, kCGBlendModeClear);
        [_content.path strokeWithBlendMode:kCGBlendModeClear alpha:0];
    } else {
        [_content.color setStroke];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
    }
    
    [_content.path stroke];
    
    CGContextRestoreGState(context);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
    
}


- (UIImage *)getImage:(UIImage *)back mask:(UIImage *)mask {
    
    const int imageWidth = mask.size.width;
    const int imageHeight = mask.size.height;
    size_t  bytesPerRow = imageWidth * 4;
    
    // 创建 mask context
    CGColorSpaceRef maskcolorSpace = CGColorSpaceCreateDeviceRGB();
    uint32_t* maskrgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    CGContextRef maskContext = CGBitmapContextCreate(maskrgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, maskcolorSpace,kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(maskContext, CGRectMake(0, 0, imageWidth, imageHeight), mask.CGImage);
    
    // 创建 back context
    CGColorSpaceRef backcolorSpace = CGColorSpaceCreateDeviceRGB();
    uint32_t* backrgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    CGContextRef backContext = CGBitmapContextCreate(backrgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, backcolorSpace,kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(backContext, CGRectMake(0, 0, imageWidth, imageHeight), back.CGImage);
    
    int pixelNum = imageWidth * imageHeight;
    
    uint32_t* maskpCurPtr = maskrgbImageBuf;
    uint32_t* backpCurPtr = backrgbImageBuf;
    
    
    for (int i = 0; i < pixelNum; i++, maskpCurPtr++){
        
        uint8_t* maskptr = (uint8_t*)maskpCurPtr;
        uint8_t* backptr = (uint8_t*)backpCurPtr;
        
        if (maskptr[3] == 255){
            maskptr[0] = 0;
            maskptr[1] = 0;
            maskptr[2] = 0;
            maskptr[3] = 0;
        }else{
            maskptr[3] = 255 - maskptr[3];
            maskptr[0] = backptr[0] * maskptr[3]/255;
            maskptr[1] = backptr[1] * maskptr[3]/255;
            maskptr[2] = backptr[2] * maskptr[3]/255;
        }
        
        backpCurPtr++;
    }
    
    // 将内存转成image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, maskrgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, backcolorSpace, kCGImageAlphaPremultipliedLast  | kCGBitmapByteOrder32Big, dataProvider,NULL, true, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(dataProvider);
    
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    return resultUIImage;
    
}

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    CGPoint point = [self touchPoint:touches];
    _content = [[PainterContent alloc] init];
    _content.color = _paintColor;
    _content.path.lineWidth = _paintWidth;
    [_content.path moveToPoint:point];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    CGPoint previousPoint2 = _content.path.currentPoint;
    CGPoint previousPoint1 = [self touchPrePoint:touches];
    CGPoint currentPoint = [self touchPoint:touches];
    [_content.path addQuadCurveToPoint:currentPoint controlPoint:previousPoint1];
    
    CGFloat minX = MIN(MIN(previousPoint2.x, previousPoint1.x), currentPoint.x);
    CGFloat minY = MIN(MIN(previousPoint2.y, previousPoint1.y), currentPoint.y);
    CGFloat maxX = MAX(MAX(previousPoint2.x, previousPoint1.x), currentPoint.x);
    CGFloat maxY = MAX(MAX(previousPoint2.y, previousPoint1.y), currentPoint.y);
    CGFloat space = _paintWidth * 0.5 + 1;
    CGRect drawRect = CGRectMake(minX-space, minY-space, maxX-minX+_paintWidth+2, maxY-minY+_paintWidth+2);
    
    [self beginDraw:drawRect];
    
}

- (CGPoint)touchPrePoint:(NSSet<UITouch *> *)touches
{
    UITouch *validTouch = nil;
    for (UITouch *touch in touches) {
        if ([touch.view isEqual:self]) {
            validTouch = touch;
            break;
        }
    }
    
    if (validTouch) {
        return [validTouch previousLocationInView:self];
    }
    else {
        return CGPointMake(-1, -1);
    }
}

- (CGPoint)touchPoint:(NSSet<UITouch *> *)touches
{
    UITouch *validTouch = nil;
    for (UITouch *touch in touches) {
        if ([touch.view isEqual:self]) {
            validTouch = touch;
            break;
        }
    }
    
    if (validTouch) {
        return [validTouch locationInView:self];
    }
    else {
        return CGPointMake(-1, -1);
    }
}

@end


@implementation PainterContent

- (instancetype)init
{
    self = [super init];
    if (self) {
        _path = [UIBezierPath bezierPath];
        _path.lineCapStyle = kCGLineCapRound;
        _path.lineJoinStyle = kCGLineJoinRound;
        _path.lineWidth = 10;
        _path.flatness = 1;
        _color = [UIColor clearColor];
    }
    
    return self;
}

@end
