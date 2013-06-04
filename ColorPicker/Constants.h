
#define kUserDefaultsFrameOriginX @"kUserDefaultsFrameOriginX"
#define kUserDefaultsFrameOriginY @"kUserDefaultsFrameOriginY"

#define kUserDefaultsKeyStartAtLogin @"kUserDefaultsKeyStartAtLogin"
#define kUserDefaultsKeyTimesRun @"kUserDefaultsKeyTimesRun"
#define kUserDefaultsColorsHistory @"kUserDefaultsColorsHistory"

#define kUserDefaultsDefaultFormat @"kUserDefaultsDefaultFormat"
#define kUserDefaultsShowMenuBarPreview @"kUserDefaultsShowMenuBarPreview"

#define kUserDefaultsKeyCode @"kUserDefaultsKeyCode"
#define kUserDefaultsModifierKeys @"kUserDefaultsModifierKeys"

#define kUserDefaultsPaletteUrl @"paletteURL"

typedef enum {
    kFormatHEX,
    kFormatRGB,
    kFormatHexWithoutHash,
    kFormatCMYK,
    kFormatUIColor,
    kFormatNSColor,
    kFormatMonoTouch
} kFormats;

#define kNumberOfColorsHistory 5

#define kAlertTitleStartupItem @"Run at Login?"                 
#define kAlertTextStartupItem @"Click \"Yes\" if you would like to run Color Picker Pro when you login."

#define kInstructions @"Color Picker Pro makes it easy to get color information from the screen.\n\nTo capture a color, simply press cmd + shift + p (you can change the shortcut in the preferences). You can see a preview of the color directly on the window or in the menu bar at any time.\n\nWhen you copy a color, it will get copied to your clipboard and added to the colors history. To copy a color back from the history simply click on it.\n\n You can hide and show the main interface by clicking on its menu bar icon, or by pressing ESC when the application is active. There are many preferences that you can tweak to customize the behavior of Color Picker."