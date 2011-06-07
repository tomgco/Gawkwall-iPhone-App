//
//  AlbumViewController.m
//  Gawk
//
//  Created by Tom Gallacher on 10/05/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import "AlbumViewController.h"
#import "GawkAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

#define DARK_BACKGROUND  [UIColor colorWithRed:151.0/255.0 green:152.0/255.0 blue:155.0/255.0 alpha:1.0]
#define LIGHT_BACKGROUND [UIColor colorWithRed:172.0/255.0 green:173.0/255.0 blue:175.0/255.0 alpha:1.0]


@implementation AlbumViewController

@synthesize tableDataSource, tmpCell, player;

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
	[tableDataSource release];    [super dealloc];
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
	UISwipeGestureRecognizer *gestures;
	gestures = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
	[gestures setDirection:UISwipeGestureRecognizerDirectionRight];
	[videoPlayer addGestureRecognizer:gestures];
	[gestures release];
	
	gestures = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
	[gestures setDirection:UISwipeGestureRecognizerDirectionLeft];
	[videoPlayer addGestureRecognizer:gestures];
	[gestures release]; 
}

-(void)handleSwipeRight:(UISwipeGestureRecognizer *)recognizer {
	NSLog(@"Swipe right received.");
	NSDictionary *cellData = [self.tableDataSource objectAtIndex:videoId];
	NSLog(@"%d", videoId);
	NSURL *gawkPath = [[[NSURL alloc] initWithString:[cellData objectForKey:@"GawkUrl"]] autorelease];
	
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.4];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromLeft];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[videoPlayer addSubview:videoView];
	[self.tableView.superview addSubview:videoPlayer];
	[[self.tableView.superview layer] addAnimation:animation forKey:@"SwipeToViewRight"];
	player =	[[MPMoviePlayerController alloc] initWithContentURL: gawkPath];
	
	player.repeatMode = MPMovieRepeatModeOne;
	player.movieSourceType = MPMovieSourceTypeFile;
	player.controlStyle = MPMovieControlStyleNone;
	[player.view setFrame: videoView.bounds];  // player's frame must match parent's
	[videoView addSubview: player.view];
	videoId = videoId == 0 ? [self.tableDataSource count] - 1 : videoId - 1;
}

-(void)handleSwipeLeft:(UISwipeGestureRecognizer *)recognizer {
	NSLog(@"Swipe left received.");
	NSLog(@"%d", videoId);
	NSDictionary *cellData = [self.tableDataSource objectAtIndex:videoId];
	NSURL *gawkPath = [[[NSURL alloc] initWithString:[cellData objectForKey:@"GawkUrl"]] autorelease];

	CATransition *animation = [CATransition animation];
	[animation setDuration:0.4];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[videoPlayer addSubview:videoView];
	[self.tableView.superview addSubview:videoPlayer];
	[[self.tableView.superview layer] addAnimation:animation forKey:@"SwipeToViewLeft"];
	player =	[[MPMoviePlayerController alloc] initWithContentURL: gawkPath];

	player.repeatMode = MPMovieRepeatModeOne;
	player.movieSourceType = MPMovieSourceTypeFile;
	player.controlStyle = MPMovieControlStyleNone;
	[player.view setFrame: videoView.bounds];  // player's frame must match parent's
	[videoView addSubview: player.view];
	videoId = videoId == ([self.tableDataSource count] - 1) ? 0 : videoId + 1;
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
	videoId = indexPath.row;
	
	NSDictionary *cellData = [self.tableDataSource objectAtIndex:indexPath.row];
	NSURL *gawkPath = [[[NSURL alloc] initWithString:[cellData objectForKey:@"GawkUrl"]] autorelease];
//	[player play];
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[self.tableView.superview addSubview:videoPlayer];
	[[self.tableView.superview layer] addAnimation:animation forKey:@"SwitchToView1"];
	player =	[[MPMoviePlayerController alloc] initWithContentURL: gawkPath];
	//player.moviePlayer.repeatMode = MPMovieRepeatModeOne;
	//[self presentMoviePlayerViewControllerAnimated:player];
	player.repeatMode = MPMovieRepeatModeOne;
	player.movieSourceType = MPMovieSourceTypeFile;
	player.controlStyle = MPMovieControlStyleNone;
	[player.view setFrame: videoView.bounds];  // player's frame must match parent's
	[videoPlayer addSubview:videoView];
	[videoView addSubview: player.view];
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

- (IBAction) backToList {
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromLeft];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[videoView removeFromSuperview];
	[videoPlayer removeFromSuperview];
	[self.tableView.superview addSubview:self.tableView];
	[player.view removeFromSuperview];
	[player release];
	[[self.tableView.superview layer] addAnimation:animation forKey:@"SwitchBackToView0"];
}

@end
