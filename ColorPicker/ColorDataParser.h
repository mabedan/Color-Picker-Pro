//
//  ColorDataParser.h
//  Color Picker Pro
//
//  Created by Mehdi Abedanzadeh on 23/01/14.
//  Copyright (c) 2014 DibiStore. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ColorDataParser <NSObject>
- (NSDictionary*) parseColorData:(NSData*)data;
@end
