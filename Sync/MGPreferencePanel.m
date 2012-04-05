	//
	//  MGPreferencePanel.m
	//  MGPreferencePanel
	//
	//  Revised by Michael on 03/03/12.
	//  Copyleft 2003-2012 MOApp Software Manufactory.
	//
    // License?
    // Do What The Fuck You Want To Public License, Version 2.



#define WINDOW_TOOLBAR_HEIGHT 78

#import "MGPreferencePanel.h"
#import "UsersController.h"

	// All you have to do is to edit the titles and images
    // You may want to use own XIB and NSWindowController instead

NSString * const AppTitle = @"Discuss.io";

NSString * const View1ItemTitle = @"Settings";
NSString * const View1ItemIdentifier = @"View1ItemIdentifier";
NSString * const View1IconImageName = @"NSPreferencesGeneral";

NSString * const View2ItemTitle = @"Account";
NSString * const View2ItemIdentifier = @"View2ItemIdentifier";
NSString * const View2IconImageName = @"NSUserAccounts";

@implementation MGPreferencePanel

@synthesize view1, view2;
@synthesize contentView;
@synthesize window;


#pragma mark -
#pragma mark INIT | AWAKE


- (id) init {
    
	if (self = [super init]) {
			//
	}	
	
	return self;
}



- (IBAction) openPane: (id) sender {
  [window makeKeyAndOrderFront:nil];
  [NSApp activateIgnoringOtherApps:YES];
	[self mapViewsToToolbar];
	[self firstPane];

  // set default values
  if ([UsersController passwordValue] != nil) {
    [password setStringValue:[UsersController passwordValue]];
  }
  [login setStringValue:[UsersController loginValue]];

  [loginCheckbox setState:[[UsersController startupValue] intValue]];
  [pasteCheckbox setState:[[UsersController pasteValue] intValue]];
  [browserCheckbox setState:[[UsersController browserValue] intValue]];

	[window center];
}



#pragma mark -
#pragma mark MAP | CHANGE


- (void) mapViewsToToolbar {
	
    NSToolbar *toolbar = [window toolbar];
	if (toolbar == nil) {        
		toolbar = [[NSToolbar alloc] initWithIdentifier: [NSString stringWithFormat: @"%@.mgpreferencepanel.toolbar", AppTitle]];
	}
	
    [toolbar setAllowsUserCustomization: NO];
    [toolbar setAutosavesConfiguration: NO];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
    
	[toolbar setDelegate: self]; 
	
	[window setToolbar: toolbar];	
	[window setTitle: View1ItemTitle];
	
	if ([toolbar respondsToSelector: @selector(setSelectedItemIdentifier:)]) {
		[toolbar setSelectedItemIdentifier: View1ItemIdentifier];
	}	
}



- (IBAction) changePanes: (id) sender {
    
	NSView *view = nil;
	
	switch ([sender tag]) 	{
		case 0:
			[window setTitle: View1ItemTitle];
			view = view1;

			break;
		case 1:
			[window setTitle: View2ItemTitle];
			view = view2;

			break;
		default:
			break;
	}
	
	NSRect windowFrame = [window frame];
	windowFrame.size.height = [view frame].size.height + WINDOW_TOOLBAR_HEIGHT;
	windowFrame.size.width = [view frame].size.width;
	windowFrame.origin.y = NSMaxY([window frame]) - ([view frame].size.height + WINDOW_TOOLBAR_HEIGHT);
	
	if ([[contentView subviews] count] != 0) {
		[[[contentView subviews] objectAtIndex:0] removeFromSuperview];
	}
	
	[window setFrame: windowFrame display: YES animate: YES];
	[contentView setFrame: [view frame]];
	[contentView addSubview: view];	
}



#pragma mark -
#pragma mark FIRST PANE


- (void) firstPane {
	NSView *view = nil;
	view = view1;
	
	NSRect windowFrame = [window frame];
	windowFrame.size.height = [view frame].size.height + WINDOW_TOOLBAR_HEIGHT;
	windowFrame.size.width = [view frame].size.width;
	windowFrame.origin.y = NSMaxY([window frame]) - ([view frame].size.height + WINDOW_TOOLBAR_HEIGHT);
	
	if ([[contentView subviews] count] != 0) {
		[[[contentView subviews] objectAtIndex:0] removeFromSuperview];
	}
	
	[window setFrame: windowFrame display: YES animate: NO];
	[contentView setFrame: [view frame]];
	[contentView addSubview: view];	
}



#pragma mark -
#pragma mark DEFAULT | ALLOWED | SELECTABLE


- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar {
    return [NSArray arrayWithObjects:
			View1ItemIdentifier,
			View2ItemIdentifier,
			nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar {
    return [NSArray arrayWithObjects:
			View1ItemIdentifier,
			View2ItemIdentifier,
			NSToolbarSeparatorItemIdentifier,
			NSToolbarSpaceItemIdentifier,
			NSToolbarFlexibleSpaceItemIdentifier,
			nil];
}


- (NSArray*) toolbarSelectableItemIdentifiers: (NSToolbar*) toolbar {
	return [NSArray arrayWithObjects:
			View1ItemIdentifier,
			View2ItemIdentifier,	
			nil];
}



#pragma mark -
#pragma mark ITEM FOR IDENTIFIER


- (NSToolbarItem*)toolbar: (NSToolbar*) toolbar itemForItemIdentifier: (NSString *) itemIdentifier willBeInsertedIntoToolbar: (BOOL) willBeInsertedIntoToolbar {
    
	NSToolbarItem *item = nil;
    if ([itemIdentifier isEqualToString: View1ItemIdentifier]) {
        item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [item setPaletteLabel: View1ItemTitle];
        [item setLabel: View1ItemTitle];
        [item setImage: [NSImage imageNamed: View1IconImageName]];
		[item setAction: @selector(changePanes:)];
		[item setTag: 0];
    }
	else if ([itemIdentifier isEqualToString: View2ItemIdentifier]) {
		
        item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [item setPaletteLabel: View2ItemTitle];
        [item setLabel: View2ItemTitle];
        [item setImage:[NSImage imageNamed: View2IconImageName]];
		[item setAction: @selector(changePanes:)];
		[item setTag: 1];
    }	
	return item;
}

@end
