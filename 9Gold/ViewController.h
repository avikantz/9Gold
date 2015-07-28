//
//  ViewController.h
//  9Gold
//
//  Created by Avikant Saini on 7/27/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerTableViewController.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, FolderPickerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *Images;
@property NSMutableArray *Favs;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

