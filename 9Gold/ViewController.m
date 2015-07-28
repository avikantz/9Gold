//
//  ViewController.m
//  9Gold
//
//  Created by Avikant Saini on 7/27/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import "ViewController.h"
#import "NineTableViewCell.h"

#define iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define SWidth self.view.frame.size.width
#define SHeight self.view.frame.size.height

@interface ViewController ()

@end

@implementation ViewController {
	UIButton *favButton;
	BOOL showingFavs;
	
	NSString *currentFolderPath;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	showingFavs = YES;
	
	_tableView.dataSource = self;
	_tableView.delegate = self;
	
	currentFolderPath = [self documentsPathForFileName:@"Favs/"];
	self.title = @"9Gold";
	
	NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentFolderPath error:nil];
	_Images = [[NSMutableArray alloc] init];
	for (NSString *item in items) {
		if ([item containsString:@".jpg"])
			[_Images addObject:[NSString stringWithFormat:@"%@/%@", currentFolderPath, item]];
	}
	
//	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//	if ([defaults objectForKey:@"fax"])
//		_Favs = [NSMutableArray arrayWithArray:[defaults objectForKey:@"fax"]];
//	else
		_Favs = [[NSMutableArray alloc] init];
	items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self documentsPathForFileName:@"Favs/"] error:nil];
	for (NSString *item in items) {
		if ([item containsString:@".jpg"])
			[_Favs addObject:[item lastPathComponent]];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)favsButtonPressed:(id)sender {
//	showingFavs = !showingFavs;
//	if (showingFavs) {
//		self.title = @"Favourites";
//		NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self documentsPathForFileName:@"Favs/"] error:nil];
//		_Images = [[NSMutableArray alloc] init];
//		for (NSString *item in items) {
//			if ([item containsString:@".jpg"])
//				[_Images addObject:[self documentsPathForFileName:item]];
//		}
//	}
//	else {
//		self.title = @"Home";
//		NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentFolderPath error:nil];
//		_Images = [[NSMutableArray alloc] init];
//		for (NSString *item in items) {
//			if ([item containsString:@".jpg"])
//				[_Images addObject:[self documentsPathForFileName:item]];
//		}
//	}
//	[_tableView reloadData];
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
}

- (NSString *)documentsPathForFileName:(NSString *)name {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	return [documentsPath stringByAppendingPathComponent:name];
}

#pragma mark - Table view data source and delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//	if (showingFavs)
//		return _Favs.count;
	return _Images.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NineTableViewCell *cell = nil;
	
	NSString *imagePath = [_Images objectAtIndex:indexPath.row];
	
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	
	if ([indexPath compare:_selectedIndexPath] == NSOrderedSame || image.size.height < 720.f) {
		cell = (NineTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"9Cell2" forIndexPath:indexPath];
	}
	else {
		cell = (NineTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"9Cell" forIndexPath:indexPath];
	}
	
	if (cell == nil)
		cell = [tableView dequeueReusableCellWithIdentifier:@"9Cell2" forIndexPath:indexPath];
	
	cell.nineImageView.image = [UIImage imageWithContentsOfFile:imagePath];
	cell.nineImageView.clipsToBounds = YES;
	
	favButton = (UIButton *)[cell viewWithTag:1];
	[favButton addTarget:self action:@selector(tableViewDidClickOnFavsButton:) forControlEvents:UIControlEventTouchUpInside];
	
	if ([_Favs containsObject:[imagePath lastPathComponent]])
		[cell.favButton setImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
	else
		[cell.favButton setImage:[UIImage imageNamed:@"checkboxEmpty"] forState:UIControlStateNormal];
	
	return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UIImage *image;
	image = [UIImage imageWithContentsOfFile:[_Images objectAtIndex:indexPath.row]];
	if ([indexPath compare:_selectedIndexPath] == NSOrderedSame || image.size.height < 720.f) {
		return (SWidth - (iPad?120:0))*image.size.height/(image.size.width);
	}
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
//	[[NSUserDefaults standardUserDefaults] setObject:_Favs forKey:@"fax"];
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

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"picker"]) {
		PickerTableViewController *pvc = [segue destinationViewController];
		pvc.delegate = self;
	}
}

@end
