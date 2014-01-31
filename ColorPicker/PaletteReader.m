//
//  PaletteReader.m
//  Color Picker Pro
//
//  Created by Mehdi Abedanzadeh on 5/31/13.
//  Copyright (c) 2013 DibiStore. All rights reserved.
//

#import "PaletteReader.h"
#import "DTColor+HTML.h"
#import "ColorDataParser.h"
#import "LessParser.h"
#import "AcoParser.h"
@implementation PaletteReader
NSDictionary *colorPalette = NULL;

#pragma mark - color handling


- (float) distanceBetween: (NSColor*) first andColor: (NSColor*) second {
    return sqrtf(powf((first.redComponent - second.redComponent), 2) + powf((first.greenComponent - second.greenComponent), 2) + powf((first.blueComponent - second.blueComponent), 2));
}

- (NSString*) getColorNameFor: (NSColor*) color {
    if (![self hasColorPalette]) {
        return @"";
    }
    NSArray *keyArray =  [colorPalette allKeys];
    NSColor *eachcolor;
    NSInteger count = [keyArray count];
    float distance;
    NSString* key;
    float threshold = 10;
    NSString *closestKey;
    for (int i=0; i < count; i++) {
        key = [keyArray objectAtIndex:i];
        eachcolor = [colorPalette objectForKey:key];
        distance = [self distanceBetween:eachcolor andColor:color];
        if (distance == 0) {
            return key;
        }
        if (threshold > distance) {
            closestKey = key;
            threshold = distance;
        }
    }
    if (closestKey) {
        return [NSString stringWithFormat:@"%@ (%.02f)", closestKey, threshold];
    }
    return @"";
}

#pragma mark - file handling

- (BOOL) hasColorPalette {
    return colorPalette != NULL;
}
- (void) checkForColorPalette {
    NSURL * url = [[NSUserDefaults standardUserDefaults] URLForKey:kUserDefaultsPaletteUrl];
    if (url) {
        [self loadColorPaletteAt:url];
    }
}
- (void) loadColorPaletteAt: (NSURL*) url {
    
    NSData *data;
    id<ColorDataParser> colorParser;
    
    data = [NSData dataWithContentsOfURL:url];
    
    //pass the data to the right parser
    if ([[url pathExtension] isEqualToString:@"less"]) {
        colorParser = [[LessParser alloc] init];
    } if ([[url pathExtension] isEqualToString:@"aco"]) {
        colorParser = [[AcoParser alloc] init];
    }
    
    colorPalette = [colorParser parseColorData:data];
    
    if (colorPalette) {
        [[NSUserDefaults standardUserDefaults] setURL:url forKey:kUserDefaultsPaletteUrl];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsPaletteUrl];
    }
}

@end
