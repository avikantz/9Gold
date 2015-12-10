//
//  NineTableViewCell.h
//  9Gold
//
//  Created by Avikant Saini on 7/27/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface NineTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *nineImageView;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIImageView *expandImageView;
@property (weak, nonatomic) IBOutlet UILabel *expandLabel;

@property (strong, nonatomic) IBOutlet MPMoviePlayerController *moviePlayer;

@end
