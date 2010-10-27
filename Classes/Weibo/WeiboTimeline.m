//
//  WeiboHomeTimeline.m
//  Rainbow
//
//  Created by Luke on 9/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboTimeline.h"


@implementation WeiboTimeline
@synthesize data,newData,lastReadId,lastReceivedId,oldestReceivedId,scrollPosition;
@dynamic unread;


-(BOOL) unread{
	return lastReadId<lastReceivedId;
}

#pragma mark  初始化
-(id)initWithWeiboConnector:(WeiboConnector*)connector timelineType:(TimelineType)type{
	if (self=[super init]) {
		weiboConnector=connector;
		timelineType=type;
		//数据初始化为nil
		data=nil;
		newData=nil;
		scrollPosition=NSMakePoint(-1, -1);
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

		[NSTimer scheduledTimerWithTimeInterval:60 
										 target:self 
									   selector:@selector(loadNewerTimeline) 
									   userInfo:nil 
										repeats:YES];
	}
	return self;
}


#pragma mark 最近信息请求的发起和处理
-(void) loadRecentTimeline{
	//when app started,execute this first
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	//不同类型的timeline不同的方法调用
	switch (timelineType) {
		case Home:
			[weiboConnector getHomeTimelineWithParameters:params
										 completionTarget:self
										 completionAction:@selector(didLoadRecentTimeline:)];
			break;
		case Mentions:
			[weiboConnector getMentionsWithParameters:params
									completionTarget:self
									 completionAction:@selector(didLoadRecentTimeline:)];
			break;
		default:
			break;
	}
}

-(void)didLoadRecentTimeline:(NSArray*)statuses{
	self.data = [[statuses mutableCopy] autorelease];
	[[data lastObject] setObject:[NSNumber numberWithInt:1] forKey:@"gap"];
	//NSMutableDictionary *gapStatus=[[statuses lastObject] mutableCopy];
	//[gapStatus setObject:[NSNumber numberWithInt:1] forKey:@"gap"];
	//[statusArray replaceObjectAtIndex:[statusArray count]-1 withObject:gapStatus];
	//NSLog(@"%@",[[statusArray lastObject] objectForKey:"gap"]);
	if (statuses!=nil&&[statuses count]>0) {		
		self.lastReceivedId=[[statuses objectAtIndex:0] objectForKey:@"id"];
        self.lastReadId = [[statuses objectAtIndex:0] objectForKey:@"id"];
		oldestReceivedId =[[[statuses lastObject] objectForKey:@"id"] retain];
		[[NSNotificationCenter defaultCenter] postNotificationName:ReloadTimelineNotification
																			object:self];
	}
}

#pragma mark 新信息请求的发起和处理
-(void)loadNewerTimeline{
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:[NSString stringWithFormat:@"%@",lastReceivedId]
			   forKey:@"since_id"];
	switch (timelineType) {
		case Home:
			[weiboConnector getHomeTimelineWithParameters:params
										 completionTarget:self
										 completionAction:@selector(didLoadNewerTimeline:)];
			break;
		case Mentions:
			[weiboConnector getMentionsWithParameters:params
									 completionTarget:self
									 completionAction:@selector(didLoadNewerTimeline:)];
			break;
		default:
			break;
	}
}

-(void)didLoadNewerTimeline:(NSArray*)statuses{
	if (statuses!=nil&&[statuses count]>0) {
		self.newData=statuses;
		NSMutableIndexSet *indexes=[NSMutableIndexSet indexSet];
		NSUInteger i, count=[statuses count];
		for(i=0;i<count;i++){
			[indexes addIndex:i];
		}
		[data insertObjects:statuses atIndexes:indexes];
		lastReceivedId=[[statuses objectAtIndex:0] objectForKey:@"id"];
		[[NSNotificationCenter defaultCenter] postNotificationName:DidLoadNewerTimelineNotification
															object:self];
		/*
		if (selected) {
			self.lastReadStatusId = [[statuses objectAtIndex:0] objectForKey:@"id"];
			[[NSNotificationCenter defaultCenter] postNotificationName:DidLoadNewerTimelineNotification
																object:statuses];
		}else {
			unread=YES;
			[[NSNotificationCenter defaultCenter] postNotificationName:UnreadNotification object:nil];
		}
		 */
	}
}

#pragma mark 历史信息请求的发起和处理


-(void)loadOlderTimeline{
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:[NSString stringWithFormat:@"%@",oldestReceivedId]
			   forKey:@"max_id"];
	NSLog(@"%@",oldestReceivedId);
	switch (timelineType) {
		case Home:
			[weiboConnector getHomeTimelineWithParameters:params
										 completionTarget:self
										 completionAction:@selector(didLoadOlderTimeline:)];
			break;
		case Mentions:
			[weiboConnector getMentionsWithParameters:params
									 completionTarget:self
									 completionAction:@selector(didLoadOlderTimeline:)];
			break;
		default:
			break;
	}
}
-(void)didLoadOlderTimeline:(NSArray*)statuses{
	if (statuses!=nil&&[statuses count]>0) {
		self.newData=statuses;
		oldestReceivedId=[[statuses lastObject] objectForKey:@"id"];
		[data addObjectsFromArray:statuses];
		[[data lastObject] setObject:[NSNumber numberWithInt:1] forKey:@"gap"];
		[[NSNotificationCenter defaultCenter] postNotificationName:DidLoadOlderTimelineNotification
															object:self];
	}
}
@end
