#import <stdlib.h>
#import "VideoTexture.h"

id<MTLTexture> _loadTexture(UIImage *image) {
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

id<MTLTexture> loadTexture(NSString *imageName) {
    UIImage *image = [UIImage imageNamed:imageName];
    return _loadTexture(image);
}

uintptr_t loadNativeTexture(const char *imageName) {
    NSString *name = [[NSString stringWithUTF8String:imageName] stringByDeletingPathExtension];
    NSString* imagePath = [[NSBundle mainBundle] pathForResource: name ofType: @"png"];
    UIImage *image = [UIImage imageWithContentsOfFile: imagePath];
    return (uintptr_t)(__bridge_retained void*) _loadTexture(image);
}

void destroyTexture(uintptr_t textureId) {
    id<MTLTexture> mtltex = (__bridge_transfer id<MTLTexture>)(void*) textureId;
    mtltex = nil;
}

int* doSomething(int x) {
    loadTexture(@"texture.png");
    int* result = (int*)malloc(sizeof(int));
    *result = x + 1;
    return result;
}
