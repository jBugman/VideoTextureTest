#import <stdlib.h>
#import "VideoTexture.h"

id<MTLTexture> loadTexture(NSString *imageName) {
    UIImage *image = [UIImage imageNamed:imageName];
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    uint8_t *rawData = (uint8_t *)calloc(height * width * 4, sizeof(uint8_t));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1, -1);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);

    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor
                          texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                       width:width
                                                      height:height
                                                   mipmapped:YES];
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    id<MTLTexture> texture = [device newTextureWithDescriptor:textureDescriptor];

    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    [texture replaceRegion:region mipmapLevel:0 withBytes:rawData bytesPerRow:bytesPerRow];

    return texture;
}

int* doSomething(int x) {
    loadTexture(@"texture.png");
    int* result = (int*)malloc(sizeof(int));
    *result = x + 1;
    return result;
}
