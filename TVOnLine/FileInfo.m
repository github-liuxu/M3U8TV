#import "FileInfo.h"

NS_ASSUME_NONNULL_BEGIN

@implementation FileInfo

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"errmsg": @"errmsg",
        @"err_no": @"errno",
        @"list": @"list",
        @"names": @"names",
        @"requestID": @"request_id",
    };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list":[QTDlinkList class],
             @"names":[QTNames class]
    };
}

@end

@implementation QTDlinkList
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"category": @"category",
        @"dlink": @"dlink",
        @"filename": @"filename",
        @"fsID": @"fs_id",
        @"isdir": @"isdir",
        @"md5": @"md5",
        @"operID": @"oper_id",
        @"path": @"path",
        @"serverCtime": @"server_ctime",
        @"serverMtime": @"server_mtime",
        @"size": @"size",
    };
}
@end

@implementation QTNames

@end

NS_ASSUME_NONNULL_END

