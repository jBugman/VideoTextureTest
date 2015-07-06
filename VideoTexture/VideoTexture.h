#import <UIKit/UIKit.h>
#import <Metal/Metal.h>


int* doSomething(int x);

id<MTLTexture> loadTexture(NSString *imageName);

uintptr_t loadNativeTexture(const char *imageName);
void destroyTexture(uintptr_t textureId);
