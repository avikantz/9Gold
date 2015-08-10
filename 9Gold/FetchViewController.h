//
//  FetchViewController.h
//  9Gold
//
//  Created by Avikant Saini on 8/4/15.
//  Copyright © 2015 avikantz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FetchViewController;
@protocol FetchProtocol <NSObject>
-(void)didFinishFetchingImages;
@end

@interface FetchViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *sectionPicker;
@property (weak, nonatomic) IBOutlet UITextField *numberOfItemsField;
@property (weak, nonatomic) IBOutlet UITextField *startIDField;
@property (weak, nonatomic) IBOutlet UITextField *pathField;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet UILabel *currentltSavingLabel;

@property (weak, nonatomic) id<FetchProtocol> delegate;

@property (strong, nonatomic) UIImage *passedImage;

@end
