/* ----------------------------------------------------------------------
 GCXDrawing.m
 
 Created by Gilo on 02.08.12.
 Copyright (c) 2012 Giulio Petek. All rights reserved.
 ---------------------------------------------------------------------- */

#import "GCXDrawing.h"

void GCXSafeDrawing(CGContextRef context, dispatch_block_t block)
{
    CGContextSaveGState(context);
    
    block();
    
    CGContextRestoreGState(context);
}

UIImage *GCXDrawImage(CGSize size, dispatch_block_t block)
{
    UIGraphicsBeginImageContext(size);
    
    GCXSafeDrawing(UIGraphicsGetCurrentContext(), block);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}