#import "QTTopLevel.h"

@implementation QTTopLevel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"err_no": @"errno",
        @"guidinfo": @"guid_info",
        @"list": @"list",
        @"requestID": @"request_id",
        @"guid": @"guid",
    };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list":[QTList class]};
}

@end

@implementation QTList
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"serverFilename": @"server_filename",
        @"privacy": @"privacy",
        @"category": @"category",
        @"unlist": @"unlist",
        @"fsID": @"fs_id",
        @"operID": @"oper_id",
        @"serverCtime": @"server_ctime",
        @"size": @"size",
        @"localMtime": @"local_mtime",
        @"md5": @"md5",
        @"share": @"share",
        @"path": @"path",
        @"localCtime": @"local_ctime",
        @"serverMtime": @"server_mtime",
        @"isdir": @"isdir",
    };
}

@end

