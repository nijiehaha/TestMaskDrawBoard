//
//  ViewController.m
//  DrawBoardTest
//
//  Created by lufei on 2019/11/25.
//  Copyright © 2019 test. All rights reserved.
//

#import "ViewController.h"
#import "NJDrawBoardView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self testDrawBoard];
    
}

/// 测试画板
- (void)testDrawBoard {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImage *originImage = [UIImage imageNamed:@"1.jpg"];
    UIImage *maskImage = [UIImage imageNamed:@"0.jpg"];
    
    CGImageRef backImageRef = [self jianbian].CGImage;
    //    CGImageRef maskRef = maskImage.CGImage;
    //    CGImageRef clearImageRef = [self clearImage].CGImage;
    //
    //    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
    //                                        CGImageGetHeight(maskRef),
    //                                        CGImageGetBitsPerComponent(maskRef),
    //                                        CGImageGetBitsPerPixel(maskRef),
    //                                        CGImageGetBytesPerRow(maskRef),
    //                                        CGImageGetDataProvider(maskRef), nil, YES);
    //    CGImageRef resultMaskImage =  CGImageCreateWithMask(backImageRef, mask);
    //    CGImageRef clearMaskImage =  CGImageCreateWithMask(clearImageRef, mask);
    
    UIImage *resMaskImage = [self get123Image:[self jianbian] mask:maskImage];
    
    NJDrawBoardView *draw = [[NJDrawBoardView alloc] initWithFrame:self.view.bounds originImage:originImage maskImage:maskImage back:[self jianbian]];
    
    [self.view addSubview:draw];
    
}

/// CALayer
- (void)testCALyer {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    
    CALayer *mask1 = [CALayer layer];
    
    mask1.frame = imageView.bounds;
    
    //    mask1.contents = (__bridge id _Nullable)([UIImage imageNamed:@"apple.png"].CGImage);
    
//    mask1.contents = (__bridge id _Nullable)(resultMaskImage);
    
//    imageView.image = [UIImage imageWithCGImage:resultMaskImage];
    
    imageView.backgroundColor = [UIColor redColor];
    //    imageView.layer.mask = mask1;
    [self.view addSubview:imageView];
    
}


- (UIImage *)get123Image:(UIImage *)back mask:(UIImage *)mask {

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

        if (maskptr[0] == 255){
            maskptr[0] = 0;
            maskptr[1] = 0;
            maskptr[2] = 0;
            maskptr[3] = 0;
        }else{
            maskptr[3] = 255 - maskptr[0];
            maskptr[0] = backptr[0] * maskptr[3]/255;
            maskptr[1] = backptr[1] * maskptr[3]/255;
            maskptr[2] = backptr[2] * maskptr[3]/255;
        }

        backpCurPtr++;
    }

    // 将内存转成image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, maskrgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData123);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, backcolorSpace, kCGImageAlphaPremultipliedLast  | kCGBitmapByteOrder32Big, dataProvider,NULL, true, kCGRenderingIntentDefault);

    CGDataProviderRelease(dataProvider);

    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];

    return resultUIImage;

}

void ProviderReleaseData123 (void *info, const void *data, size_t size){
    free((void*)data);
}

- (UIImage *)clearImage
{
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect = self.view.bounds;
    
    [[UIColor blueColor] setFill];
    
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
    
}

- (UIImage *)jianbian
{
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    
    [self drawColorLinearGradientWithRect:self.view.frame];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
    
}

- (void)drawColorLinearGradientWithRect:(CGRect)rect{
    
    CGContextRef  context = UIGraphicsGetCurrentContext();
    
    size_t num_locations = 2;
    CGPoint startPoint = CGPointMake(0, 0), endPoint = CGPointMake(0, rect.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {1,0,0,1,
        0,1,0,1};
    CGFloat locations[] = {0.0, 1.0};
    
    CGGradientRef gradientObject = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
    
    //切换最后一个参数可以查看相关效果
    CGContextDrawLinearGradient(context, gradientObject, startPoint, endPoint, 0);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradientObject);
    
}

@end
