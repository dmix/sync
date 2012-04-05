#import <Foundation/Foundation.h>
#import "SCEventListenerProtocol.h"
#import "AFHTTPClient.h"
#import "JSONKit.h"

@interface WatchController : NSObject <SCEventListenerProtocol>
{
	SCEvents *_events;
  NSMutableArray *_currentFiles;
  IBOutlet NSMenu *statusMenu;
}

@property (nonatomic, copy, getter=currentFiles, setter=setCurrentFiles:) NSMutableArray *_currentFiles;

- (void)setupEventListener;
- (NSArray *)filesIn:(NSString *)dir;
- (NSArray *)uniqueFilesFom:(NSArray *)arrayA:(NSArray *)arrayB;
- (IBAction) openDFolder: (id) sender;
- (IBAction) launchWebsite: (id) sender;
- (void)uploadFile:(NSString *)path:(NSString *)file;
- (BOOL) writeToPasteBoard:(NSString *)stringToWrite;

@end