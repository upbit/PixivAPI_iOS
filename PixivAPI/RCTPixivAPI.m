#import "RCTPixivAPI.h"

@implementation RCTPixivAPI

RCT_EXPORT_MODULE()

#define PAPI_CALL(...) do { \
  NSDictionary *object = [[[PixivAPI sharedInstance] __VA_ARGS__] toObject]; \
  callback(@[[RCTPixivAPI toJSONString:object]]); \
} while(0)

#define PAPI_LIST_CALL(...) do { \
  NSArray *array = [[[PixivAPI sharedInstance] __VA_ARGS__] toObjectList]; \
  callback(@[[RCTPixivAPI toJSONString:array]]); \
} while(0)

#pragma mark - JSON helper

+ (NSString *)toJSONString:(id)data
{
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
  return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark - Common exports

RCT_EXPORT_METHOD(loginIfNeeded:(NSString *)username password:(NSString *)password
                  callback:(RCTResponseSenderBlock)callback)
{
  BOOL success = [[PixivAPI sharedInstance] loginIfNeeded:username password:password];
  callback(@[[NSNumber numberWithBool:success]]);
}

#pragma mark - PAPI exports

RCT_EXPORT_METHOD(PAPI_works:(NSInteger)illust_id callback:(RCTResponseSenderBlock)callback)
{
  PAPI_CALL(PAPI_works:illust_id);
}

RCT_EXPORT_METHOD(PAPI_users:(NSInteger)author_id callback:(RCTResponseSenderBlock)callback)
{
  PAPI_CALL(PAPI_users:author_id);
}

RCT_EXPORT_METHOD(PAPI_me_feeds:(BOOL)show_r18 callback:(RCTResponseSenderBlock)callback)
{
  PAPI_LIST_CALL(PAPI_me_feeds:show_r18);
}

RCT_EXPORT_METHOD(PAPI_users_works:(NSInteger)author_id page:(NSInteger)page publicity:(BOOL)publicity callback:(RCTResponseSenderBlock)callback)
{
  PAPI_LIST_CALL(PAPI_users_works:author_id page:page publicity:publicity);
}

RCT_EXPORT_METHOD(PAPI_users_favorite_works:(NSInteger)author_id page:(NSInteger)page publicity:(BOOL)publicity callback:(RCTResponseSenderBlock)callback)
{
  PAPI_LIST_CALL(PAPI_users_favorite_works:author_id page:page publicity:publicity);
}

RCT_EXPORT_METHOD(PAPI_ranking_all:(NSString *)mode page:(NSInteger)page callback:(RCTResponseSenderBlock)callback)
{
  PAPI_LIST_CALL(PAPI_ranking_all:mode page:page);
}

RCT_EXPORT_METHOD(PAPI_ranking_log:(NSString *)mode page:(NSInteger)page date:(NSString *)date callback:(RCTResponseSenderBlock)callback)
{
  PAPI_LIST_CALL(PAPI_ranking_log:mode page:page date:date);
}

@end
