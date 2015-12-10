//
//  NineTableViewCell.m
//  9Gold
//
//  Created by Avikant Saini on 7/27/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import "NineTableViewCell.h"

@implementation NineTableViewCell

- (void)awakeFromNib {
    // Initialization code
	self.moviePlayer = [[MPMoviePlayerController alloc] init];
	self.moviePlayer.controlStyle = MPMovieControlStyleNone;
	self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
	self.moviePlayer.repeatMode = MPMovieRepeatModeOne;
	[self.contentView addSubview:self.moviePlayer.view];
}

-(void)layoutSubviews {
	[super layoutSubviews];
	self.moviePlayer.view.frame = CGRectMake(10, 0, self.bounds.size.width - 20, self.bounds.size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
