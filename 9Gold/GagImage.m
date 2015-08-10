//
//  GagImage.m
//  9GAG Downloader
//
//  Created by Avikant Saini on 8/4/15.
//  Copyright © 2015 avikantz. All rights reserved.
//

#import "GagImage.h"

@implementation GagImage

-(instancetype)initWithData:(id)data {
	self = [super init];
	if (self) {
		self.ID = [data valueForKey:@"id"];
		self.URL = [data valueForKey:@"link"];
		self.Caption = [data valueForKey:@"caption"];
		
		self.ImageNormalURL = [[data valueForKey:@"images"] valueForKey:@"normal"];
		self.ImageLargeURL = [[data valueForKey:@"images"] valueForKey:@"large"];
		
		if ([self.ImageLargeURL containsString:@"460c"]) {
			self.ImageNormalURL = [NSString stringWithFormat:@"http://img-9gag-fun.9cache.com/photo/%@_460s.jpg", self.ID];
			self.ImageLargeURL = [NSString stringWithFormat:@"http://img-9gag-fun.9cache.com/photo/%@_700b.jpg", self.ID];
		}
		
		self.VotesCount = [[[data valueForKey:@"votes"] valueForKey:@"count"] integerValue];
	}
	return self;
}

+(id)returnArrayFromData:(id)data {
	NSMutableArray *gags = [[NSMutableArray alloc] init];
	for (id gag in data) {
		GagImage *gagImage = [[GagImage alloc] initWithData:gag];
		[gags addObject:gagImage];
	}
	return gags;
}

@end
