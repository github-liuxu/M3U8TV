// Generated with quicktype
// For more options, try https://app.quicktype.io

#import <Foundation/Foundation.h>

@class QTTopLevel;
@class QTList;

NS_ASSUME_NONNULL_BEGIN

@interface QTTopLevel : NSObject
@property (nonatomic, assign) NSInteger err_no;
@property (nonatomic, strong) NSString *guidInfo;
@property (nonatomic, strong) NSArray<QTList *> *list;
@property (nonatomic, assign) NSInteger requestID;
@property (nonatomic, assign) NSInteger guid;

@end

@interface QTList : NSObject
@property (nonatomic, strong) NSString *serverFilename;
@property (nonatomic, assign) NSInteger privacy;
@property (nonatomic, assign) NSInteger category;
@property (nonatomic, assign) NSInteger unlist;
@property (nonatomic, assign) NSInteger fsID;
@property (nonatomic, assign) NSInteger operID;
@property (nonatomic, assign) NSInteger serverCtime;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, assign) NSInteger localMtime;
@property (nonatomic, strong) NSString *md5;
@property (nonatomic, assign) NSInteger share;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) NSInteger localCtime;
@property (nonatomic, assign) NSInteger serverMtime;
@property (nonatomic, assign) NSInteger isdir;
@end

NS_ASSUME_NONNULL_END

