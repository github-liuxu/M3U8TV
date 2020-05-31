// Generated with quicktype
// For more options, try https://app.quicktype.io

#import <Foundation/Foundation.h>

@class FileInfo;
@class QTDlinkList;
@class QTNames;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface FileInfo : NSObject
@property (nonatomic, strong) NSString *errmsg;
@property (nonatomic, assign) NSInteger err_no;
@property (nonatomic, strong) NSArray<QTDlinkList *> *list;
@property (nonatomic, strong) QTNames *names;
@property (nonatomic, strong) NSString *requestID;

@end

@interface QTDlinkList : NSObject
@property (nonatomic, assign) NSInteger category;
@property (nonatomic, strong) NSString *dlink;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, assign) NSInteger fsID;
@property (nonatomic, assign) NSInteger isdir;
@property (nonatomic, strong) NSString *md5;
@property (nonatomic, assign) NSInteger operID;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) NSInteger serverCtime;
@property (nonatomic, assign) NSInteger serverMtime;
@property (nonatomic, assign) NSInteger size;
@end

@interface QTNames : NSObject
@end

NS_ASSUME_NONNULL_END

