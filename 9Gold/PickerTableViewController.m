//
//  PickerTableViewController.m
//  9Gold
//
//  Created by Avikant Saini on 7/28/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import "PickerTableViewController.h"

@interface PickerTableViewController ()

@end

@implementation PickerTableViewController {
	NSMutableArray *pickerArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	
	NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self documentsPathForFileName:@""] error:nil];
	pickerArray = [[NSMutableArray alloc] init];
	for (NSString *item in items) {
		if (![[item lastPathComponent] containsString:@"."])
			[pickerArray addObject:[self documentsPathForFileName:item]];
	}
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)documentsPathForFileName:(NSString *)name {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	return [documentsPath stringByAppendingPathComponent:name];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return pickerArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pickerCell" forIndexPath:indexPath];
	if (cell == nil)
		cell = [tableView dequeueReusableCellWithIdentifier:@"pickerCell"];
	
	NSString *path = [pickerArray objectAtIndex:indexPath.row];
	cell.textLabel.text = [path lastPathComponent];
	
	if ([cell.textLabel.text isEqualToString:@"Favs"])
		cell.imageView.image = [UIImage imageNamed:@"favs"];
	else
		cell.imageView.image = [UIImage imageNamed:@"folder"];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		// download image on global queue
		NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
		__block CGFloat size = 0;
		[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			size += ([[[NSFileManager defaultManager] attributesOfItemAtPath:[path stringByAppendingPathComponent:obj] error:nil] fileSize])/pow(10, 6);
		}];
		// save image to documents folder for further use
		
		dispatch_async(dispatch_get_main_queue(), ^{
			// Get the current cell on the main queue and set the image
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%li items, %.1f MB", array.count, size];
		});
	});
	
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *path = pickerArray[indexPath.row];
	[self.delegate didPickFolderWithName:[path lastPathComponent] andPath:[path stringByAppendingString:@"/"]];
	[self dismissViewControllerAnimated:YES completion:^{
	}];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		NSString *path = pickerArray[indexPath.row];
		[pickerArray removeObject:path];
		NSError *error;
		[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 64.f;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Choose a folder";
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
