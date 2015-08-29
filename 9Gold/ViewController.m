//
//  ViewController.m
//  9Gold
//
//  Created by Avikant Saini on 7/27/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import "ViewController.h"
#import "NineTableViewCell.h"
#import "TTOpenInAppActivity.h"
#import "AFBlurSegue.h"

#define iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define SWidth self.view.frame.size.width
#define SHeight self.view.frame.size.height

@interface ViewController () <MCSwipeTableViewCellDelegate>

@end

@implementation ViewController {
	UIButton *favButton;
	BOOL showingFavs;
	
	NSString *currentFolderPath;
	
	UILongPressGestureRecognizer *longPressGesture;
	UIImage *imageToShare;
	NSURL *urlToShare;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.view.backgroundColor = [UIColor blackColor];
	self.tableView.backgroundColor = [UIColor blackColor];
	self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
	
	_tableView.dataSource = self;
	_tableView.delegate = self;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if ([defaults objectForKey:@"folderPath"]) {
		currentFolderPath = [self documentsPathForFileName:[defaults objectForKey:@"folderPath"]];
		self.title = [defaults objectForKey:@"folderPath"];
	}
	else {
		currentFolderPath = [self documentsPathForFileName:@"Favs/"];
		self.title = @"9Gold";
	}
	
	showingFavs = ([currentFolderPath containsString:@"Favs"])?YES:NO;
	
	NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentFolderPath error:nil];
	_Images = [[NSMutableArray alloc] init];
	for (NSString *item in items) {
		if ([item containsString:@".jpg"])
			[_Images addObject:[NSString stringWithFormat:@"%@/%@", currentFolderPath, item]];
	}
	
	_Favs = [[NSMutableArray alloc] init];
	items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self documentsPathForFileName:@"Favs/"] error:nil];
	for (NSString *item in items) {
		if ([item containsString:@".jpg"])
			[_Favs addObject:[item lastPathComponent]];
	}
	
	longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongPressCell:)];
	[longPressGesture setNumberOfTouchesRequired:1];
	[longPressGesture setMinimumPressDuration:0.8f];
	[self.tableView addGestureRecognizer:longPressGesture];
	
	if ([defaults floatForKey:@"scrollOffset"])
		[_tableView setContentOffset:CGPointMake(0, [defaults floatForKey:@"scrollOffset"]) animated:YES];
	
	// Handling scroll offset
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		CGFloat scrollOffset = [_tableView contentOffset].y;
		NSString *path = currentFolderPath;
		[defaults setFloat:scrollOffset forKey:@"scrollOffset"];
		[defaults setObject:[path lastPathComponent] forKey:@"folderPath"];
	}];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void)didPickFolderWithName:(NSString *)name andPath:(NSString *)path {
	currentFolderPath = path;
	self.title = name;
	NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentFolderPath error:nil];
	_Images = [[NSMutableArray alloc] init];
	for (NSString *item in items) {
		if ([item containsString:@".jpg"])
			[_Images addObject:[self documentsPathForFileName:[NSString stringWithFormat:@"%@/%@", name, item]]];
	}
	showingFavs = NO;
	if ([name isEqualToString:@"Favs"])
		showingFavs = YES;
	[_tableView reloadData];
	[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (NSString *)documentsPathForFileName:(NSString *)name {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	return [documentsPath stringByAppendingPathComponent:name];
}

- (IBAction)shuffleArray:(id)sender {
	NSMutableArray *array = _Images;
	NSInteger count = (long)[array count];
	for (NSUInteger i = 0; i < count; ++i) {
		NSInteger exchangeIndex = arc4random_uniform((int)count);
		if (i != exchangeIndex) {
			[array exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
		}
	}
	_Images = array;
	[UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		self.tableView.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width, 0);
		self.tableView.alpha = 0.f;
	} completion:^(BOOL finished) {
		self.tableView.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width, 0);
		[self.tableView reloadData];
		[UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			self.tableView.transform = CGAffineTransformIdentity;
			self.tableView.alpha = 1.f;
		} completion:nil];
	}];
}


#pragma mark - Table view data source and delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _Images.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NineTableViewCell *cell = nil;
	
	NSString *imagePath = [_Images objectAtIndex:indexPath.row];
	
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	
	if ([indexPath compare:_selectedIndexPath] == NSOrderedSame || image.size.height < 1440.f)
		cell = (NineTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"9Cell2" forIndexPath:indexPath];
	else
		cell = (NineTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"9Cell" forIndexPath:indexPath];
	
	if (cell == nil)
		cell = [tableView dequeueReusableCellWithIdentifier:@"9Cell2" forIndexPath:indexPath];
	
	cell.nineImageView.image = [UIImage imageWithContentsOfFile:imagePath];
	cell.nineImageView.clipsToBounds = YES;
	
	favButton = (UIButton *)[cell viewWithTag:1];
	[favButton addTarget:self action:@selector(tableViewDidClickOnFavsButton:) forControlEvents:UIControlEventTouchUpInside];
	
	if ([_Favs containsObject:[imagePath lastPathComponent]])
		[cell.favButton setImage:[UIImage imageNamed:@"favs"] forState:UIControlStateNormal];
	else
		[cell.favButton setImage:[UIImage imageNamed:@"checkboxEmpty"] forState:UIControlStateNormal];
	
	
	// Configuring the views and colors.
	UIView *checkView = [self viewWithImageName:@"favs"];
	UIColor *greenColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];
	
	UIView *crossView = [self viewWithImageName:@"cross"];
	UIColor *redColor = [UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0];
	
	// Adding gestures per state basis.
	[cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
		NSString *imagePath;
		NSError *error;
		if (showingFavs) {
			imagePath = [_Images objectAtIndex:indexPath.row];
			[_Images removeObject:imagePath];
			[_Favs removeObject:[imagePath lastPathComponent]];
			[[NSFileManager defaultManager] removeItemAtPath:[self documentsPathForFileName:[NSString stringWithFormat:@"Favs/%@", [imagePath lastPathComponent]]] error:&error];
			[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		}
		else {
			imagePath = [_Images objectAtIndex:indexPath.row];
			if ([_Favs containsObject:[imagePath lastPathComponent]]) {
				[_Favs removeObject:[imagePath lastPathComponent]];
				[[NSFileManager defaultManager] removeItemAtPath:[self documentsPathForFileName:[NSString stringWithFormat:@"Favs/%@", [imagePath lastPathComponent]]] error:&error];
			}
			else {
				[_Favs addObject:[imagePath lastPathComponent]];
				[[NSFileManager defaultManager] copyItemAtPath:imagePath toPath:[self documentsPathForFileName:[NSString stringWithFormat:@"Favs/%@", [imagePath lastPathComponent]]] error:&error];
			}
			[_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
		}
	}];
	
	[cell setSwipeGestureWithView:crossView color:redColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
		[self tableView:tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
	}];
	
	
	return cell;
}

- (UIView *)viewWithImageName:(NSString *)imageName {
	UIImage *image = [UIImage imageNamed:imageName];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	imageView.contentMode = UIViewContentModeCenter;
	return imageView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UIImage *image;
	image = [UIImage imageWithContentsOfFile:[_Images objectAtIndex:indexPath.row]];
	if ([indexPath compare:_selectedIndexPath] == NSOrderedSame || image.size.height < 1440.f)
		return (SWidth - (iPad?120:0))*image.size.height/(image.size.width);
	return 320.f + (iPad?160:0);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView beginUpdates];
	if (![indexPath compare:_selectedIndexPath] == NSOrderedSame)
		_selectedIndexPath = indexPath;
	else
		_selectedIndexPath = nil;
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[tableView endUpdates];
	[tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)tableViewDidClickOnFavsButton:(id)sender {
	CGPoint pointOfOrigin = [sender convertPoint:CGPointZero toView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pointOfOrigin];
	NSString *imagePath;
	NSError *error;
	if (showingFavs) {
		imagePath = [_Images objectAtIndex:indexPath.row];
		[_Images removeObject:imagePath];
		[_Favs removeObject:[imagePath lastPathComponent]];
		[[NSFileManager defaultManager] removeItemAtPath:[self documentsPathForFileName:[NSString stringWithFormat:@"Favs/%@", [imagePath lastPathComponent]]] error:&error];
		[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	else {
		imagePath = [_Images objectAtIndex:indexPath.row];
		if ([_Favs containsObject:[imagePath lastPathComponent]]) {
			[_Favs removeObject:[imagePath lastPathComponent]];
			[[NSFileManager defaultManager] removeItemAtPath:[self documentsPathForFileName:[NSString stringWithFormat:@"Favs/%@", [imagePath lastPathComponent]]] error:&error];
		}
		else {
			[_Favs addObject:[imagePath lastPathComponent]];
			[[NSFileManager defaultManager] copyItemAtPath:imagePath toPath:[self documentsPathForFileName:[NSString stringWithFormat:@"Favs/%@", [imagePath lastPathComponent]]] error:&error];
		}
		[_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

-(void)LongPressCell :(UILongPressGestureRecognizer *)recognizer {
	CGPoint pointOfContact = [recognizer locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pointOfContact];
	NSString *path = [_Images objectAtIndex:indexPath.row];
	imageToShare = [UIImage imageWithContentsOfFile:path];
	urlToShare = [NSURL URLWithString:[NSString stringWithFormat:@"http://9gag.com/gag/%@", [[path lastPathComponent] substringToIndex:7]]];
	TTOpenInAppActivity *openInAppActivity = [[TTOpenInAppActivity alloc] initWithView:self.view andRect:recognizer.view.frame];
	if (indexPath == nil) {
		// Long press not on a row...
	}
	else if (recognizer.state == UIGestureRecognizerStateBegan) {
		// Long press recognized on indexPath.row
		UIActivityViewController *ShareAVC = [[UIActivityViewController alloc] initWithActivityItems:
											  @[imageToShare, urlToShare] applicationActivities:@[openInAppActivity]];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:ShareAVC];
			openInAppActivity.superViewController = popup;
			[popup presentPopoverFromRect:_tableView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUnknown animated:YES];
		}
		else {
			openInAppActivity.superViewController = ShareAVC;
			[self presentViewController:ShareAVC animated:TRUE completion:nil];
		}
	}
	else {
		// Recognizer didn't recognize the gesture
	}
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSError *error;
		NSString *path = [_Images objectAtIndex:indexPath.row];
		[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
		[_Images removeObject:path];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *path = [_Images objectAtIndex:indexPath.row];
	if (!showingFavs && ![_Favs containsObject:[path lastPathComponent]])
		return YES;
	return NO;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"infoFooter" owner:self options:nil] objectAtIndex:0];
	UILabel *textLabel = (UILabel *)[view viewWithTag:1];
	textLabel.text = [currentFolderPath lastPathComponent];
	UILabel *detailTextLabel = (UILabel *)[view viewWithTag:2];
	detailTextLabel.text = [NSString stringWithFormat:@"%li items.", [_Images count]];
	UIImageView *imageView = (UIImageView *)[view viewWithTag:3];
	if ([textLabel.text containsString:@"Favs"])
		imageView.image = [UIImage imageNamed:@"favs"];
	else
		imageView.image = [UIImage imageNamed:@"folder"];
	return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 84.f;
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"picker"]) {
		PickerTableViewController *pvc = [segue destinationViewController];
		pvc.delegate = self;
	}
}

@end
