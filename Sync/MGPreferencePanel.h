	//
	//  MGPreferencePanel.h
	//  MGPreferencePanel
	//
	//  Revised by Michael on 03/03/12.
	//  Copyleft 2003-2012 MOApp Software Manufactory.
	//
    // License?
    // Do What The Fuck You Want To Public License, Version 2.


#import <Cocoa/Cocoa.h>

@interface MGPreferencePanel : NSObject <NSToolbarDelegate> {
  IBOutlet NSTextField *login;
  IBOutlet NSTextField *password;
  IBOutlet NSButton *loginCheckbox;
  IBOutlet NSButton *browserCheckbox;
  IBOutlet NSButton *pasteCheckbox;
  IBOutlet NSButton *growlCheckbox;
}

@property (readwrite, retain) IBOutlet NSView *view1;
@property (readwrite, retain) IBOutlet NSView *view2;
@property (readwrite, retain) IBOutlet NSView *contentView;
@property (readwrite, retain) IBOutlet NSWindow *window;

- (void) mapViewsToToolbar;
- (void) firstPane;
- (IBAction) openPane: (id) sender;
- (IBAction) changePanes: (id) sender;

@end
