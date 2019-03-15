//
//  UIImage+Category.h
//  OpenGL
//
//  Created by jyd on 2019/3/6.
//  Copyright © 2019年 jyd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Category)


/** 绘制图片圆角 */
- (UIImage *)drawCircleImage:(CGSize)size;

/** 切割图片圆角 */
- (UIImage *)clipCircleImage:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
