//
//  PickerTableViewController.h
//  9Gold
//
//  Created by Avikant Saini on 7/28/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PickerTableViewController;
@protocol FolderPickerDelegate <NSObject>
-(void)didPickFolderWithName:(NSString *)name andPath:(NSString *)path;
@end

@interface PickerTableViewController : UITableViewController <UIAlertViewDelegate>

@property (weak, nonatomic) id<FolderPickerDelegate> delegate;

@end
