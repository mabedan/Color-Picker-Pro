//
//  AcoParser.m
//  Color Picker Pro
//
//  Created by Mehdi Abedanzadeh on 23/01/14.
//  Copyright (c) 2014 DibiStore. All rights reserved.
//

#import "AcoParser.h"

@implementation AcoParser
struct aco* parsedAco;
int ind;
NSArray *intArray;


- (NSDictionary*) parseColorData : (NSData*) data {
    NSDictionary* ret;
    ind = 0;
    intArray = [self arrayFromData: data];
    
    while (!parsedAco) {
        parsedAco = readaco();
    }
    
    
    if (!parsedAco) {
        return FALSE;
    }
    if (parsedAco->len > 0) {
        
        int j;
        int cols = 4;
        
        NSMutableDictionary* mutable = [[NSMutableDictionary alloc] init];
        
        for (j = 0; j < parsedAco->len; j += cols) {
            int i;
            for (i = 0; i < cols; i++) {
                float r, g, b;
                char *name;
                
                if (j+i == parsedAco->len) break;
                struct acoentry entry = parsedAco->color[j+i];
                r = entry.r / 256.0;
                g = entry.g / 256.0;
                b = entry.b / 256.0;
                name = entry.name;
                [mutable setObject:[NSColor colorWithCalibratedRed:r green:g blue:b alpha:0] forKey:[NSString stringWithFormat:@"%s", name]];
            }
        }
        ret = [NSDictionary dictionaryWithDictionary:mutable];
    } else {
        ret = nil;
    }
    return ret;
}
- (NSArray *) arrayFromData: (NSData*) data {
    const void *bytes = data.bytes;
    NSMutableArray *ary = [NSMutableArray array];
    for (NSUInteger i = 0; i < [data length]; i += sizeof(int16_t)) {
        int16_t elem = OSReadLittleInt16(bytes, i);
        [ary addObject:[NSNumber numberWithInt:elem]];
    }
    return ary;
}

/* proper error handling is not for lazy people ;) */
static void *acomalloc(size_t len)
{
    void *ptr = malloc(len);
    if (ptr == NULL) {
        fprintf(stderr, "Out of memory!\n");
        exit(1);
    }
    return ptr;
}

struct acoentry {
    unsigned char r, g, b;
    char *name; /* NULL if no name is available */
};

struct aco {
    int ver;    /* ACO file version, 1 or 2 */
    int len;    /* number of colors */
    struct acoentry *color; /* array of colors as acoentry structures */
};


/* Convert the color read from 'fp' according to the .aco file version.
 * On success zero is returned and the pass-by-reference parameters
 * populated, otherwise non-zero is returned.
 *
 * The color name is stored in the 'name' buffer that can't
 * hold more than 'buflen' bytes including the nul-term. */
static int convertcolor(int ver, int *r, int *g, int *b,
                        char *name, int buflen)
{
    int cspace = mustreadword();
    int namelen;
    
    if (cspace != 0) {
        int j;
        for (j = 0; j < 4; j++) mustreadword();
        if (ver == 2) {
            mustreadword();
            namelen = mustreadword();
            for (j = 0; j < namelen; j++)
                mustreadword();
        }
        fprintf(stderr, "Non RGB color (colorspace %d) skipped\n", cspace);
        return 1;
    }
    
    /* data in common between version 1 and 2 record */
    
    *r = mustreadword()/256;
    *g = mustreadword()/256;
    *b = mustreadword()/256;
    mustreadword(); /* just skip this word, (Z not used for RGB) */
    if (ver == 1) return 0;
    
    /* version 2 specific data (name) */
    
    mustreadword(); /* just skip this word, don't know what it's used for */
    /* Color name, only for version 1 */
    namelen = mustreadword();
    namelen--;
    while(namelen > 0) {
        int c = mustreadword();
        
        if (c > 0xff) /* To handle utf-16 here is an overkill ... */
            c = ' ';
        if (buflen > 1) {
            *name++ = c;
            buflen--;
        }
        namelen--;
    }
    *name='\0';
    mustreadword(); /* Skip the nul term */
    return 0;
}

/* Read a 16bit word in big endian from 'fp' and return it
 * converted in the host byte order as usigned int.
 * On end of file -1 is returned. */
static int readword() {
    if (ind < intArray.count) {
        return intArray[ind];
    } else {
        return -1;
    }
}
/* Version of readword() that exists with an error message
 * if an EOF occurs */
static int mustreadword() {
    int w;
    
    w = readword();
    if (w == -1) {
        fprintf(stderr, "Unexpected end of file!\n");
        exit(1);
    }
    return w;
}


/* Read an ACO file from 'infp' FILE and return
 * the structure describing the palette.
 *
 * On initial end of file NULL is returned.
 * That's not a real library to read this format but just
 * an hack in order to write this convertion utility, so
 * on error we just exit(1) brutally after priting an error. */
static struct aco *readaco()
{
    int ver;
    int colors;
    int j;
    struct aco *aco;
    
    /* Read file version */
    ver = readword();
    if (ver == -1) return NULL;
    fprintf(stderr, "reading ACO stream version:");
    if (ver == 1) {
        fprintf(stderr, " 1 (photoshop < 7.0)\n");
    } else if (ver == 2) {
        fprintf(stderr, " 2 (photoshop >= 7.0)\n");
    } else {
        fprintf(stderr, "Unknown ACO file version %d. Exiting...\n", ver);
        exit(1);
    }
    
    /* Read number of colors in this file */
    colors = readword();
    fprintf(stderr, "%d colors in this file\n", colors);
    
    /* Allocate memory */
    aco = acomalloc(sizeof(*aco));
    aco->len = colors;
    aco->color = acomalloc(sizeof(struct acoentry)*aco->len);
    aco->ver = ver;
    
    /* Convert every color inside */
    for(j=0; j < colors; j++) {
        int r,g,b;
        char name[256];
        
        if (convertcolor(ver, &r, &g, &b, name, 256)) continue;
        aco->color[j].r = r;
        aco->color[j].g = g;
        aco->color[j].b = b;
        aco->color[j].name = NULL;
        if (ver == 2)
            aco->color[j].name = strdup(name); /* NULL means no name anyway */
    }
    return aco;
}

@end
