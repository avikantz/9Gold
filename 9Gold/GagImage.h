//
//  GagImage.h
//  9GAG Downloader
//
//  Created by Avikant Saini on 8/4/15.
//  Copyright © 2015 avikantz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GagImage : NSObject

@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) NSString *URL;
@property (strong, nonatomic) NSString *Caption;

@property (strong, nonatomic) NSString *ImageNormalURL;
@property (strong, nonatomic) NSString *ImageLargeURL;

@property NSInteger VotesCount;

-(instancetype)initWithData:(id)data;
+(id)returnArrayFromData:(id)data;

@end
