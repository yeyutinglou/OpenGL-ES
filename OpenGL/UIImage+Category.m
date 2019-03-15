//
//  UIImage+Category.m
//  OpenGL
//
//  Created by jyd on 2019/3/6.
//  Copyright © 2019年 jyd. All rights reserved.
//

#import "UIImage+Category.h"

@implementation UIImage (Category)

- (UIImage *)drawCircleImage:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef ref = UIGraphicsGetCurrentContext();
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    CGContextAddEllipseInRect(ref, rect);
    
    CGContextClip(ref);
    
    [self drawInRect:rect];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}


- (UIImage *)clipCircleImage:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:50] addClip];
    
    [self drawInRect:rect];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
