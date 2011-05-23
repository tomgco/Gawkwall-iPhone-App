//
//  AlbumViewController.m
//  Gawk
//
//  Created by Tom Gallacher on 10/05/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import "AlbumViewController.h"
#import "GawkAppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>

#define DARK_BACKGROUND  [UIColor colorWithRed:151.0/255.0 green:152.0/255.0 blue:155.0/255.0 alpha:1.0]
#define LIGHT_BACKGROUND [UIColor colorWithRed:172.0/255.0 green:173.0/255.0 blue:175.0/255.0 alpha:1.0]


@implementation AlbumViewController

@synthesize tableDataSource, tmpCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
	[tableDataSource release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
		NSArray *tempArray = [[NSArray alloc] init];
		self.tableDataSource = tempArray;
		[tempArray release];
	
	self.tableDataSource = [[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] data] objectForKey:@"Rows"];

	self.tableView.rowHeight = 73.0;
	self.tableView.backgroundColor = DARK_BACKGROUND;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
	[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] saveUserGawks];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.tableDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ApplicationCell";
    
    ApplicationCell *cell = (ApplicationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"AlbumViewCell" owner:self options:nil];
			cell = tmpCell;
			self.tmpCell = nil;

    }
	
	// Display dark and light background in alternate rows -- see tableView:willDisplayCell:forRowAtIndexPath:.
	cell.useDarkBackground = (indexPath.row % 2 == 0);
    
	NSDictionary *dictionary = [self.tableDataSource objectAtIndex:indexPath.row];
	cell.wall = [dictionary objectForKey:@"GawkUrl"];
	cell.date = [dictionary objectForKey:@"DateCreated"];
	cell.icon = [UIImage imageWithContentsOfFile:[dictionary objectForKey:@"Thumbnail"]];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = ((ApplicationCell *)cell).useDarkBackground ? DARK_BACKGROUND : LIGHT_BACKGROUND;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSDictionary *cellData = [self.tableDataSource objectAtIndex:indexPath.row];
	NSURL *gawkPath = [[NSURL alloc] initWithString:[cellData objectForKey:@"GawkUrl"]];
	MPMoviePlayerViewController *player =	[[MPMoviePlayerViewController alloc] initWithContentURL: gawkPath];
	player.moviePlayer.repeatMode = MPMovieRepeatModeOne;
	[self presentMoviePlayerViewControllerAnimated:player];
//	player.repeatMode = MPMovieRepeatModeOne;
//	player.movieSourceType = MPMovieSourceTypeFile;
//	player.controlStyle = MPMovieControlStyleNone;
//	[player.view setFrame: videoPlayer.bounds];  // player's frame must match parent's
//	[videoPlayer addSubview: player.view];
//	[UIView transitionFromView:self.view toView:videoPlayer duration:0.75 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
//	[player play];
	[gawkPath release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSMutableArray *dataItems = [[[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] data] objectForKey:@"Rows"] mutableCopy];
		[dataItems removeObjectAtIndex:indexPath.row];
		NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
		[data setObject:dataItems forKey:@"Rows"];
		[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] resetData:data];
		self.tableDataSource = [[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] data] objectForKey:@"Rows"];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView reloadData];
}
@end
