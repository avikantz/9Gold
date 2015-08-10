//
//  PickerTableViewController.m
//  9Gold
//
//  Created by Avikant Saini on 7/28/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import "PickerTableViewController.h"
#import "PickerEditerTableViewCell.h"
#import "AFBlurSegue.h"

#define SWidth self.view.frame.size.width
#define SHeight self.view.frame.size.height

@interface PickerTableViewController ()

@end

@implementation PickerTableViewController {
	NSMutableArray *pickerArray;
	NSIndexPath *indexPathToDelete;
	
	UILongPressGestureRecognizer *longPressGesture;
	NSIndexPath *selectedIndexPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.tableView setContentOffset:CGPointMake(0, -44.f) animated:YES];
	
	NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self documentsPathForFileName:@""] error:nil];
	pickerArray = [[NSMutableArray alloc] init];
	NSString *favItem = @"";
	for (NSString *item in items) {
		if (![[item lastPathComponent] containsString:@"."]) {
			[pickerArray addObject:[self documentsPathForFileName:item]];
			if ([item containsString:@"Favs"])
				favItem = [self documentsPathForFileName:item];
		}
	}
	
	[pickerArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
	
	[pickerArray removeObject:favItem];
	[pickerArray insertObject:favItem atIndex:0];
	
	longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongPressCell:)];
	[longPressGesture setNumberOfTouchesRequired:1];
	[longPressGesture setMinimumPressDuration:1.f];
	[self.tableView addGestureRecognizer:longPressGesture];
	selectedIndexPath = nil;
	
	[self.refreshControl addTarget:self action:@selector(didFinishFetchingImages) forControlEvents:UIControlEventAllEvents];
	[self.tableView addSubview:self.refreshControl];
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
	PickerEditerTableViewCell *cell;
	NSString *path = [pickerArray objectAtIndex:indexPath.row];
	NSString *folderName = [path lastPathComponent];
	if ([indexPath isEqual:selectedIndexPath]) {
		cell = (PickerEditerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"pickerEditorCell" forIndexPath:indexPath];
		if ([folderName containsString:@"Favs"])
			cell.editorImageView.image = [UIImage imageNamed:@"favs"];
		else
			cell.editorImageView.image = [UIImage imageNamed:@"folder"];
		cell.editorTextField.text = folderName;
		cell.editorTextField.delegate = self;
		[cell.editorTextField becomeFirstResponder];
	}
	else {
		cell = [tableView dequeueReusableCellWithIdentifier:@"pickerCell" forIndexPath:indexPath];
		cell.textLabel.text = folderName;
		if ([folderName containsString:@"Favs"])
			cell.imageView.image = [UIImage imageNamed:@"favs"];
		else
			cell.imageView.image = [UIImage imageNamed:@"folder"];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			// get the attributes of folders on another queue
			NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
			__block CGFloat size = 0;
			[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				size += ([[[NSFileManager defaultManager] attributesOfItemAtPath:[path stringByAppendingPathComponent:obj] error:nil] fileSize])/pow(10, 6);
			}];
			dispatch_async(dispatch_get_main_queue(), ^{
				// Get the current cell on the main queue and set the folder attributes
				UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%li items, %.1f MB", array.count, size];
			});
		});
	}
	
	if (cell == nil)
		cell = [tableView dequeueReusableCellWithIdentifier:@"pickerCell"];
	
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 48.f;
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
		// set index path of the row, and prompt the user
		indexPathToDelete = indexPath;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Delete?" message:[NSString stringWithFormat:@"This will delete the folder '%@' and all its contents. The action is irreversible. Are you sure you want to continue?", [[pickerArray objectAtIndex:indexPath.row] lastPathComponent]] delegate:self cancelButtonTitle:@"Nope." otherButtonTitles:@"Do it.", nil];
		[alert show];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 80.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"footer" owner:self options:nil] objectAtIndex:0];
	UIButton *button = (UIButton *)[view viewWithTag:2];
	[button addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
	UIButton *fetchImagesButton = (UIButton *)[view viewWithTag:3];
	[fetchImagesButton addTarget:self action:@selector(presentFetchViewController) forControlEvents:UIControlEventTouchUpInside];
	return view;
}

#pragma mark - Text field delegates

-(BOOL)textFieldShouldReturn:(nonnull UITextField *)textField {
	NSString *path = pickerArray[selectedIndexPath.row];
	NSFileManager *manager = [NSFileManager defaultManager];
	if ([manager fileExistsAtPath:path]) {
		NSError *error;
		if (![manager moveItemAtPath:path toPath:[[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:textField.text] error:&error])
			NSLog(@"Error: %@", error.localizedDescription);
	}
	selectedIndexPath = nil;
	[self didFinishFetchingImages];
	[self.tableView reloadData];
	[textField resignFirstResponder];
	return YES;
}

#pragma mark - Other

-(void)dismissViewController {
	[self dismissViewControllerAnimated:YES completion:^{
	}];
}

-(void)presentFetchViewController {
	FetchViewController *fvc = [self.storyboard instantiateViewControllerWithIdentifier:@"fetchViewController"];
	fvc.delegate = self;
//	AFBlurSegue *segue = [AFBlurSegue segueWithIdentifier:@"fetchSegue" source:self destination:fvc performHandler:^{
//	}];
//	[self prepareForSegue:segue sender:self];
//	[self performSegueWithIdentifier:segue.identifier sender:self];
	[self presentViewController:fvc animated:YES completion:^{
	}];
}

-(void)didFinishFetchingImages {
	NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self documentsPathForFileName:@""] error:nil];
	pickerArray = [[NSMutableArray alloc] init];
	NSString *favItem = @"";
	for (NSString *item in items) {
		if (![[item lastPathComponent] containsString:@"."]) {
			[pickerArray addObject:[self documentsPathForFileName:item]];
			if ([item containsString:@"Favs"])
				favItem = [self documentsPathForFileName:item];
		}
	}
	
	[pickerArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
	
	[pickerArray removeObject:favItem];
	[pickerArray insertObject:favItem atIndex:0];
	
	[self.tableView reloadData];
}

-(void)LongPressCell :(UILongPressGestureRecognizer *)recognizer {
	CGPoint pointOfContact = [recognizer locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pointOfContact];
	if (indexPath == nil) {
		// Long press not on a row...
	}
	else if (recognizer.state == UIGestureRecognizerStateBegan) {
		// Long press recognized on indexPath.row
		selectedIndexPath = indexPath;
		[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	else {
		// Recognizer didn't recognize the gesture
	}
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

#pragma mark - Alert view delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
	if ([title isEqualToString:@"Do it."]) {
		NSString *pathToDelete = pickerArray[indexPathToDelete.row];
		[pickerArray removeObject:pathToDelete];
		NSError *error;
		[[NSFileManager defaultManager] removeItemAtPath:pathToDelete error:&error];
		[self.tableView deleteRowsAtIndexPaths:@[indexPathToDelete] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"fetchSegue"]) {
		
	}
}


@end
