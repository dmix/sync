#import <Foundation/Foundation.h>
#import "SCEventListenerProtocol.h"
#import "AFHTTPClient.h"
#import "JSONKit.h"

@interface WatchController : NSObject <SCEventListenerProtocol>
{
	SCEvents *_events;
  NSMutableArray *_currentFiles;
  NSOperationQueue *_queue;
  IBOutlet NSMenu *statusMenu;
}

@property (nonatomic, copy, getter=currentFiles, setter=setCurrentFiles:) NSMutableArray *_currentFiles;
@property (nonatomic, copy) NSOperationQueue *_queue;

- (void)setupEventListener;
- (NSArray *)filesIn:(NSString *)dir;
- (NSArray *)uniqueFilesFom:(NSArray *)arrayA:(NSArray *)arrayB;
- (void)newFileDetect:(NSString *)watchPath;
- (void)uploadFile:(NSString *)path:(NSString *)file;

@end
