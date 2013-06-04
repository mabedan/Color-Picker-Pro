
#import <Foundation/Foundation.h>

@interface PaletteReader : NSObject

- (NSString*) getColorNameFor: (NSColor*) color;
- (BOOL) hasColorPalette;
- (void) loadColorPaletteAt: (NSURL*) url;
- (float) distanceBetween: (NSColor*)crl andColor: (NSColor* )crll;
- (void) checkForColorPalette;
@end
