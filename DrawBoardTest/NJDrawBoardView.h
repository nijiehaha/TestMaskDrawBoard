//
//  NJDrawBoardView.h
//  testImage
//
//  Created by lufei on 2019/3/8.
//  Copyright © 2019年 leqi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NJDrawBoardView : UIImageView


/**
 初始化方法

 @param frame 布局
 @param originImage 原图
 @param maskImage 遮罩
 @return NJDrawBoardView
 */
- (instancetype)initWithFrame:(CGRect)frame originImage:(UIImage *)originImage maskImage:(UIImage *)maskImage back:(UIImage *)back;

@property (nonatomic, strong) UIColor *paintColor;
@property (nonatomic, assign) CGFloat paintWidth;

@end

@interface PainterContent : NSObject

@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, strong) UIColor *color;

@end

NS_ASSUME_NONNULL_END
