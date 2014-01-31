//
//  LessParser.m
//  Color Picker Pro
//
//  Created by Mehdi Abedanzadeh on 23/01/14.
//  Copyright (c) 2014 DibiStore. All rights reserved.
//

#import "LessParser.h"
#import "DTColor+HTML.h"

@implementation LessParser
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
- (NSDictionary*) parseColorData:(NSData*)data {
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
        return [NSDictionary dictionaryWithDictionary:mutable];
    } else {
        return nil;
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
