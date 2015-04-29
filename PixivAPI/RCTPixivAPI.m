#import "RCTPixivAPI.h"

@implementation RCTPixivAPI

RCT_EXPORT_MODULE()

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

#pragma mark - SAPI exports

#define SAPI_LIST_CALL(...) do { \
  NSMutableArray *results = [[NSMutableArray alloc] init]; \
  NSArray *illusts = [[PixivAPI sharedInstance] __VA_ARGS__]; \
  for (SAPIIllust *illust in illusts) [results addObject:[illust toObject]]; \
  callback(@[[RCTPixivAPI toJSONString:results]]); \
} while(0)

RCT_EXPORT_METHOD(SAPI_ranking:(NSInteger)page mode:(NSString *)mode content:(NSString *)content
                  requireAuth:(BOOL)requireAuth callback:(RCTResponseSenderBlock)callback)
{
  SAPI_LIST_CALL(SAPI_ranking:page mode:mode content:content requireAuth:requireAuth);
}

RCT_EXPORT_METHOD(SAPI_ranking_log:(NSInteger)Date_Year month:(NSInteger)Date_Month day:(NSInteger)Date_Day
                  mode:(NSString *)mode page:(NSInteger)page requireAuth:(BOOL)requireAuth callback:(RCTResponseSenderBlock)callback)
{
  SAPI_LIST_CALL(SAPI_ranking_log:Date_Year month:Date_Month day:Date_Day mode:mode page:page requireAuth:requireAuth);
}

RCT_EXPORT_METHOD(SAPI_member_illust:(NSInteger)author_id page:(NSInteger)page
                  requireAuth:(BOOL)requireAuth callback:(RCTResponseSenderBlock)callback)
{
  SAPI_LIST_CALL(SAPI_member_illust:author_id page:page requireAuth:requireAuth);
}

#pragma mark - PAPI exports

#define PAPI_CALL(...) do { \
  NSDictionary *object = [[[PixivAPI sharedInstance] __VA_ARGS__] toObject]; \
  callback(@[[RCTPixivAPI toJSONString:object]]); \
} while(0)

#define PAPI_LIST_CALL(...) do { \
  NSArray *array = [[[PixivAPI sharedInstance] __VA_ARGS__] toObjectList]; \
  callback(@[[RCTPixivAPI toJSONString:array]]); \
} while(0)

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

RCT_EXPORT_METHOD(PAPI_users_favorite_works:(NSInteger)author_id page:(NSInteger)page publicity:(BOOL)publicity
                  callback:(RCTResponseSenderBlock)callback)
{
  PAPI_LIST_CALL(PAPI_users_favorite_works:author_id page:page publicity:publicity);
}

@end
