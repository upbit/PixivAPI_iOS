//
//  PixivFetcher.m
//  PixivDaily
//
//  Created by Zhou Hao on 14-8-29.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "PixivFetcher.h"

// API root server
#define PIXIV_SAPI_ROOT @"http://spapi.pixiv.net/iphone/"

// match state for parsePayload()
typedef NS_ENUM(NSUInteger, PARSER_STATE) {
    PARSER_STATE_NONE = 0,              // not match
    PARSER_STATE_DQUOTES = 1,           // first "
    PARSER_STATE_DQUOTES_CLOSE = 2      // check "...(["],)|(["]")
};

@implementation PixivFetcher

#pragma mark - SPAI URL

+ (NSURL *)URLForQuery:(NSString *)query
{
    query = [NSString stringWithFormat:@"%@%@", PIXIV_SAPI_ROOT, query];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:query];
}

/**
 *  ranking.php?content={all, male, female, original}&mode={day, week, month}&p={1-n}
 */
+ (NSURL *)URLforRanking:(NSUInteger)page mode:(NSString *)mode content:(NSString *)content
{
    return [self URLForQuery:[NSString stringWithFormat:@"ranking.php?content=%@&mode=%@&p=%u", content, mode, (page>0)?page:1]];
}
/**
 *  illust.php?illust_id={id}
 */
+ (NSURL *)URLforIllust:(NSUInteger)illust_id
{
    return [self URLForQuery:[NSString stringWithFormat:@"illust.php?illust_id=%u", illust_id]];
}
/**
 *  member_illust.php?id={id}&p={1-n}
 */
+ (NSURL *)URLforMemberIllust:(NSUInteger)authorId page:(NSUInteger)page
{
    return [self URLForQuery:[NSString stringWithFormat:@"member_illust.php?id=%u&p=%u", authorId, page]];
}
/**
 *  user.php?level={3}&user_id={id}
 */
+ (NSURL *)URLforUser:(NSUInteger)userId level:(NSUInteger)level
{
    return [self URLForQuery:[NSString stringWithFormat:@"user.php?level=%u&user_id=%u", level, userId]];
}

#pragma mark - URL Fetcher

/**
 *  Async fetch URL
 */
+ (void)asyncURLFetch:(NSURL *)url completionHandler:(AsyncCompletionBlock)handler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"http://spapi.pixiv.net/" forHTTPHeaderField:@"Referer"];
    [request setValue:@"pixiv-ios-app(ver4.0.0)" forHTTPHeaderField:@"User-Agent"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:handler];
}

/**
 *  Async fetch URL and decode to IllustModel
 *
 *  @param url              API URL
 *  @param isIllust         YES - Illust; NO - Author
 *  @param onSuccessHandler callback when fetch Success
 *  @param onFailureHandler callback when fetch Failure
 */
+ (void)asyncFetchIllust:(NSURL *)url isIllust:(BOOL)isIllust
               onSuccess:(SuccessIllustBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    [PixivFetcher asyncURLFetch:url completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        if (!connectionError && responseCode == 200) {
            NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"pixiv return: %@", payload);
            IllustModel *illust = [PixivFetcher parsePayload:payload];
            if (illust) {
                onSuccessHandler(illust, isIllust);
            } else {
                onFailureHandler(response, responseCode, data, connectionError);
            }
        } else {
            onFailureHandler(response, responseCode, data, connectionError);
        };
    }];
}

/**
 *  Async fetch URL and decode to NSArray of IllustModel
 *
 *  @param url              API URL
 *  @param isIllust         YES - Illust; NO - Author
 *  @param onSuccessHandler callback when fetch Success
 *  @param onFailureHandler callback when fetch Failure
 */
+ (void)asyncFetchIllustList:(NSURL *)url isIllust:(BOOL)isIllust
                   onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    [PixivFetcher asyncURLFetch:url completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        if (!connectionError && responseCode == 200) {
            NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"pixiv return: %@", payload);
            onSuccessHandler([PixivFetcher parsePayloadList:payload], isIllust);
        } else {
            onFailureHandler(response, responseCode, data, connectionError);
        };
    }];
}

#pragma mark - Data Parser

/**
 *  Pixiv SAPI result State Machine
 *
 *  @param payload SPAI line record
 *
 *  @return Array of NSString
 */
+ (IllustModel *)parsePayload:(NSString *)payload
{
    PARSER_STATE matchState = PARSER_STATE_NONE;
    NSString *token = @"";
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [payload length]; i++) {
        NSString *c = [payload substringWithRange:NSMakeRange(i, 1)];
        
        switch (matchState) {
            case PARSER_STATE_NONE:
                if ([c isEqualToString:@"\""]) {
                    matchState = PARSER_STATE_DQUOTES;
                    token = @"";
                } else if ([c isEqualToString:@","]) {
                    [result addObject:token];
                    token = @"";
                } else {
                    token = [token stringByAppendingString:c];
                }
                break;
                
            case PARSER_STATE_DQUOTES:
                if ([c isEqualToString:@"\""]) {
                    matchState = PARSER_STATE_DQUOTES_CLOSE;    // check
                } else {
                    token = [token stringByAppendingString:c];
                }
                break;
                
            case PARSER_STATE_DQUOTES_CLOSE:
                if ([c isEqualToString:@"\""]) {
                    matchState = PARSER_STATE_DQUOTES;          // found "", it's a " in string
                    [token stringByAppendingString:@"\""];
                } else {
                    [result addObject:token];
                    token = @"";
                    matchState = PARSER_STATE_NONE;
                }
                break;
        }
    }
    
    return [PixivFetcher parseDataArrayToModel:result];
}

+ (NSArray *)parsePayloadList:(NSString *)payload
{
    NSMutableArray *listResult = [[NSMutableArray alloc] init];
    NSArray *inputLines = [payload componentsSeparatedByString:@"\n"];
    
    for (NSString *line in inputLines) {
        IllustModel *illust = [PixivFetcher parsePayload:line];
        if (illust) {
            [listResult addObject:illust];
        }
    }
    
    return listResult;
}

/**
 *  Parse payload NSArray to IllustModel
 *
 *  @param array payload property array from pixiv
 *
 *  @return illust class
 */
+ (IllustModel *)parseDataArrayToModel:(NSArray *)data
{
    if ([data count] < MIN_PIXIV_RECORD_FIELDS_NUM)
        return nil;
    
    IllustModel *illust = [[IllustModel alloc] init];
    
    illust.illustId = [(NSString *)data[0] intValue];
    illust.authorId = [(NSString *)data[1] intValue];
    illust.ext = data[2];
    illust.title = data[3];
    illust.server = data[4];
    illust.authorName = data[5];
    illust.thumbURL = data[6];
    illust.mobileURL = data[9];
    illust.date = data[12];
    illust.tags = [data[13] componentsSeparatedByString:@" "];
    illust.tool = data[14];
    illust.feedbacks = [(NSString *)data[15] intValue];
    illust.points = [(NSString *)data[16] intValue];
    illust.views = [(NSString *)data[17] intValue];
    illust.comment = data[18];
    illust.pages = [(NSString *)data[19] intValue];
    illust.bookmarks = [(NSString *)data[22] intValue];
    illust.username = data[24];
    
    return illust;
}

#pragma mark - Pixiv API

+ (void)API_getRanking:(NSUInteger)page mode:(NSString *)mode content:(NSString *)content
                onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSURL *url = [PixivFetcher URLforRanking:page mode:mode content:content];
    [PixivFetcher asyncFetchIllustList:url isIllust:YES onSuccess:onSuccessHandler onFailure:onFailureHandler];
}

+ (void)API_getIllust:(NSUInteger)illustId
             onSuccess:(SuccessIllustBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSURL *url = [PixivFetcher URLforIllust:illustId];
    [PixivFetcher asyncFetchIllust:url isIllust:YES onSuccess:onSuccessHandler onFailure:onFailureHandler];
}

+ (void)API_getMemberIllust:(NSUInteger)authorId page:(NSUInteger)page
            onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSURL *url = [PixivFetcher URLforMemberIllust:authorId page:page];
    [PixivFetcher asyncFetchIllustList:url isIllust:YES onSuccess:onSuccessHandler onFailure:onFailureHandler];
}

+ (void)API_getUser:(NSUInteger)authorId
          onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSURL *url = [PixivFetcher URLforUser:authorId level:3];
    [PixivFetcher asyncFetchIllustList:url isIllust:NO onSuccess:onSuccessHandler onFailure:onFailureHandler];
}

@end
