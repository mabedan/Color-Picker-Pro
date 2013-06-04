//
//  PaletteReader.m
//  Color Picker Pro
//
//  Created by Mehdi Abedanzadeh on 5/31/13.
//  Copyright (c) 2013 DibiStore. All rights reserved.
//

#import "PaletteReader.h"
#import "DTColor+HTML.h"

@implementation PaletteReader
NSDictionary *colorPalette = NULL;
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
    
    BOOL success = FALSE;
    
    //pass the data to the right parser
    if ([[url pathExtension] isEqualToString:@"less"]) {
        data = [NSData dataWithContentsOfURL:url];
        success= [self parseLessData:data];
    } /*if ([[url pathExtension] isEqualToString:@"aco"]) {}*/
    
    if (success) {
        [[NSUserDefaults standardUserDefaults] setURL:url forKey:kUserDefaultsPaletteUrl];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsPaletteUrl];
    }
}


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
#pragma mark - lessparser
/*
 extremely basic parser.
 only supports less files filled with colors. anything else will cause the file to be unreadable.
 less variables are not supported, nor color calculations.
 farther contributions are welcome.
 
 double dash comments are accepted.
 example:
/////////////

 @my-precious-color: red;
 @my-red: rgb(255,0,0);
 
/////////////
 
 */
- (BOOL) parseLessData:(NSData*)data {
    NSString *output = [[[NSString alloc]initWithData:data
                                             encoding:NSUTF8StringEncoding]
                        stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    BOOL insideComment = FALSE;
    
    NSMutableDictionary* mutable = [[NSMutableDictionary alloc] init];
    BOOL success = FALSE;
    BOOL isBreak = FALSE;
    int lineStart = 0;
    unichar chara;
    
    for (int i = 0; i < output.length; i++) {
        chara = [output characterAtIndex:i];
        isBreak = chara == '\n' || [output characterAtIndex:i] == '\r';
        if (insideComment && isBreak) {
            lineStart = i;
            insideComment = FALSE;
            continue;
        }
        
        if (chara == '/' && output.length > i+1 && [output characterAtIndex:i+1] == '/') {
            success = [self processLessLine:[output substringWithRange:NSMakeRange(lineStart, i - lineStart)] to:mutable] || success;
            insideComment = TRUE;
            i++;
            continue;
        }
        if (chara == ';' && !insideComment) {
            success = [self processLessLine:[output substringWithRange:NSMakeRange(lineStart, i - lineStart)] to:mutable] || success;
            lineStart = i;
            continue;
        }
    }
    if (success) {
        colorPalette = [NSDictionary dictionaryWithDictionary:mutable];
        return TRUE;
    } else {
        return FALSE;
    }

}

- (BOOL) processLessLine: (NSString*) line to: (NSMutableDictionary*) dic{
    NSString *name;
    NSString *colorString;
    NSColor *color;
    NSArray *parts;
    line = [line stringByReplacingOccurrencesOfString:@";" withString:@""];
    line = [line stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    line = [line stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (line.length < 4) {
        return FALSE;
    }
    parts = [line componentsSeparatedByString:@":"];
    name = [parts objectAtIndex:0];
    colorString = [parts objectAtIndex:1];
    color = [NSColor colorWithHTMLName:colorString];
    if (color) {
        [dic setObject:color forKey:name];
    }
    if (!color) {
        color = [NSColor colorWithHexString:colorString];
    }
    if (color) {
        [dic setObject:color forKey:name];
        return TRUE;
    }
    return FALSE;
}

@end
