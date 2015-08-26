//
//  FetchViewController.m
//  9Gold
//
//  Created by Avikant Saini on 8/4/15.
//  Copyright © 2015 avikantz. All rights reserved.
//

#import "FetchViewController.h"
#import "GagImage.h"

@interface FetchViewController ()

@end

@implementation FetchViewController {
	CGFloat incProgress;
	NSString *currentlySaving;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	
}

- (IBAction)saveAction:(id)sender {
	[_progressView setProgress:0 animated:YES];
	
	NSString *section;
	switch (_sectionPicker.selectedSegmentIndex) {
		case 0: section = @"hot";
			break;
		case 1: section = @"trending";
			break;
		default: section = @"hot";
			break;
	}
	
	__block NSInteger savedCount = 0;
	__block NSString *next = @"0";
	if (_startIDField.text != nil)
		next = _startIDField.text;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		while (savedCount < [_numberOfItemsField.text integerValue]) {
			NSError *error;
			NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self urlForSection:section andID:next]]];
			if (urlData) {
				NSData *data = [NSJSONSerialization JSONObjectWithData:urlData options:kNilOptions error:&error];
				
				if (!error && data) {
					NSMutableArray *gagImages = [GagImage returnArrayFromData:[data valueForKey:@"data"]];
					next = [[data valueForKey:@"paging"] valueForKey:@"next"];
					
					for (NSInteger i = 0; i < gagImages.count; ++i) {
						GagImage *gag = [gagImages objectAtIndex:i];
						NSData *image = nil;
						image = [NSData dataWithContentsOfURL:[NSURL URLWithString:gag.ImageNormalURL]];
						if (image)
							[image writeToFile:[self imagesPathForFileName:[gag.ImageNormalURL lastPathComponent]] atomically:YES];
						currentlySaving = [NSString stringWithFormat:@"Saving '%@'", [gag.ImageNormalURL lastPathComponent]];
						incProgress = [_numberOfItemsField.text integerValue]/savedCount;
						[self performSelectorOnMainThread:@selector(updateProgressView) withObject:nil waitUntilDone:YES];
					}
				}
				savedCount += 10;
			}
		}
		[self.delegate didFinishFetchingImages];
		currentlySaving = @"Done...";
		[self performSelectorOnMainThread:@selector(updateProgressView) withObject:nil waitUntilDone:YES];
	});
}

-(void)updateProgressView {
	[_progressView setProgress:incProgress animated:YES];
	_currentltSavingLabel.text = currentlySaving;
}

- (NSString *)urlForSection:(NSString *)section andID:(NSString *)ID {
	NSString *string = [NSString stringWithFormat:@"http://infinigag.eu01.aws.af.cm/%@/%@", section, ID];
	return string;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[_numberOfItemsField resignFirstResponder];
	[_startIDField resignFirstResponder];
	[_pathField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(nonnull UITextField *)textField {
	[textField resignFirstResponder];
	if ([textField isEqual:_pathField])
		[self saveAction:self];
	else if ([textField isEqual:_numberOfItemsField])
		[_startIDField becomeFirstResponder];
	else if ([textField isEqual:_startIDField])
		[_pathField becomeFirstResponder];
	
	return YES;
}

- (NSString *)imagesPathForFileName:(NSString *)name {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [NSString stringWithFormat:@"%@", [paths lastObject]];
	[manager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@/", [paths lastObject], _pathField.text] withIntermediateDirectories:YES attributes:nil error:nil];
	return [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", _pathField.text, name]];
}

- (IBAction)doneAction:(id)sender {
	[self dismissViewControllerAnimated:YES completion:^{
	}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
