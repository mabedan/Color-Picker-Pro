//
//  PreferencesViewController.m
//  Color Picker
//
//  Created by Oscar Del Ben on 9/6/11.
//  Copyright 2011 DibiStore. All rights reserved.
//

#import "PreferencesController.h"
#import "RSLoginItems.h"
#import "CustomStatusItem.h"
#import "SRRecorderControl.h"
#import "SRRecorderCell.h"
#import "AppController.h"

@implementation PreferencesController
@synthesize defaultFormat;
@synthesize openAtLogin;
@synthesize showColorPreview;
@synthesize loginItems;
@synthesize statusItemView;
@synthesize appController;
@synthesize recorderView;

- (id)init
{
    self = [super initWithWindowNibName:@"PreferencesController"];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib
{
    defaultFormat.tag    = kOptionDefaultFormat;
    openAtLogin.tag      = kOptionOpenAtLogin;
    showColorPreview.tag = kOptionShowColorPreview;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [defaultFormat selectItemAtIndex:[userDefaults integerForKey:kUserDefaultsDefaultFormat]];
    openAtLogin.state = [userDefaults boolForKey:kUserDefaultsKeyStartAtLogin];
    showColorPreview.state = [userDefaults boolForKey:kUserDefaultsShowMenuBarPreview];
    // Set the default shortcut text
    [self setFilePickerTitle];
 
    NSInteger code = [[userDefaults valueForKey:kUserDefaultsKeyCode] longValue];
    NSInteger flags = [[userDefaults valueForKey:kUserDefaultsModifierKeys] longValue];
    
    SRRecorderCell *cell = (SRRecorderCell *)[recorderView cell];
    cell.keyCombo = SRMakeKeyCombo(code, flags);
}

- (void)paletteFileOpener:(id)sender {
    NSOpenPanel *openpanel = [NSOpenPanel openPanel];
    openpanel.canChooseFiles = TRUE;
    [openpanel setAllowedFileTypes:[NSArray arrayWithObjects:@"LESS", nil]];
//    [openpanel setAllowedFileTypes:[NSImage imageFileTypes]];
    openpanel.canCreateDirectories = FALSE;
    [openpanel beginWithCompletionHandler: ^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSURL*  theDoc = [[openpanel URLs] objectAtIndex:0];
            [appController.paletteReader loadColorPaletteAt:theDoc];
            // Open  the document.
            [self setFilePickerTitle];           
        }
        
    }];
}

- (void) setFilePickerTitle {
    //file might have been broken or empty, therefore we check again
    NSURL *url = [[NSUserDefaults standardUserDefaults] URLForKey:kUserDefaultsPaletteUrl];
    if (url) {
        NSString* lastComponent = [url lastPathComponent];
        [[self palettePicker] setTitle: lastComponent];
    } else {
        [[self palettePicker] setTitle: @"Browse"];
    }
}

- (IBAction)controllerChanged:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    switch ([sender tag]) {
        case kOptionDefaultFormat:
            [userDefaults setObject:[NSNumber numberWithLong:[defaultFormat indexOfSelectedItem]] forKey:kUserDefaultsDefaultFormat];
            break;
        case kOptionOpenAtLogin:
            if ([sender state])	{
				[userDefaults setBool:YES forKey:kUserDefaultsKeyStartAtLogin];
				[self.loginItems addAppAsLoginItem];
			}
			else {
				[userDefaults setBool:NO forKey:kUserDefaultsKeyStartAtLogin];
				[self.loginItems deleteAppFromLoginItem];
			}
            break;
        case kOptionShowColorPreview:
            [userDefaults setObject:[NSNumber numberWithBool:[sender state]] forKey:kUserDefaultsShowMenuBarPreview];
            statusItemView.showPreview = [sender state];
            [statusItemView setNeedsDisplay:YES];
            break;
    }
        
    [userDefaults synchronize];
}


//- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason
//{
//    return NO;
//}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo
{
    [appController unregisterHotKey];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:[NSNumber numberWithLong:newKeyCombo.code] forKey:kUserDefaultsKeyCode];
    [userDefaults setObject:[NSNumber numberWithLong:newKeyCombo.flags] forKey:kUserDefaultsModifierKeys];
     
    [appController registerHotKey];
}


@end
