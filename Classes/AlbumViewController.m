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

@interface AlbumViewController ()
- (void)favGawkFailed:(ASIHTTPRequest *)request;
- (void)favGawkFinished:(ASIHTTPRequest *)request;
@end

@implementation AlbumViewController

@synthesize tableDataSource, tmpCell, player;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
			self.tableDataSource = [[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] data] objectForKey:@"Rows"];
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
	[videoViewContainer addGestureRecognizer:gestures];
	[gestures release];
	
	gestures = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
	[gestures setDirection:UISwipeGestureRecognizerDirectionLeft];
	[videoViewContainer addGestureRecognizer:gestures];
	[gestures release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContent) name:@"ReloadAlbumView" object:nil];
}

-(void)handleSwipeRight:(UISwipeGestureRecognizer *)recognizer {
	[self goRight];
}

-(void)handleSwipeLeft:(UISwipeGestureRecognizer *)recognizer {
	[self goLeft];
}

- (IBAction) goLeft {
	videoId = videoId == ([self.tableDataSource count] - 1) ? 0 : videoId + 1;
	NSDictionary *cellData = [self.tableDataSource objectAtIndex:videoId];
	NSURL *gawkPath = [[[NSURL alloc] initWithString:[cellData objectForKey:@"GawkUrl"]] autorelease];
	wallName.text = [cellData objectForKey:@"RelatedWall"];
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.4];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[videoViewContainer addSubview:videoView];
	CGRect frame = videoPlayer.frame;
	frame.origin.y = 20.0;
	videoPlayer.frame = frame;
	[videoPlayer addSubview:videoViewContainer];
	//[self.tabBarController.tabBar setHidden:YES];
	[[videoViewContainer layer] addAnimation:animation forKey:@"SwipeViewToLeft"];
	player =	[[MPMoviePlayerController alloc] initWithContentURL: gawkPath];
	
	player.repeatMode = MPMovieRepeatModeOne;
	player.movieSourceType = MPMovieSourceTypeFile;
	player.controlStyle = MPMovieControlStyleNone;
	player.scalingMode = MPMovieScalingModeAspectFill;
	[player.view setFrame: videoView.bounds];  // player's frame must match parent's
	[videoView addSubview: player.view];
}

- (IBAction) goRight {
	videoId = videoId == 0 ? [self.tableDataSource count] - 1 : videoId - 1;
	NSDictionary *cellData = [self.tableDataSource objectAtIndex:videoId];
	wallName.text = [cellData objectForKey:@"RelatedWall"];
	NSURL *gawkPath = [[[NSURL alloc] initWithString:[cellData objectForKey:@"GawkUrl"]] autorelease];
	
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.4];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromLeft];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[videoViewContainer addSubview:videoView];
	CGRect frame = videoPlayer.frame;
	frame.origin.y = 20.0;
	videoPlayer.frame = frame;
	[videoPlayer addSubview:videoViewContainer];
	//[self.tabBarController.tabBar setHidden:YES];
	[[videoViewContainer layer] addAnimation:animation forKey:@"SwipeViewToRight"];
	player =	[[MPMoviePlayerController alloc] initWithContentURL: gawkPath];
	
	player.repeatMode = MPMovieRepeatModeOne;
	player.movieSourceType = MPMovieSourceTypeFile;
	player.controlStyle = MPMovieControlStyleNone;
	player.scalingMode = MPMovieScalingModeAspectFill;
	[player.view setFrame: videoView.bounds];  // player's frame must match parent's
	[videoView addSubview: player.view];
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
	[self refreshContent];

}

-(void) refreshContent {
	NSArray *tempArray = [[NSArray alloc] init];
	self.tableDataSource = tempArray;
	[tempArray release];
	
	self.tableDataSource = [[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] data] objectForKey:@"Rows"];
	[self.tableView reloadData];
	CGPoint contentOffset = CGPointMake(0,[[NSUserDefaults standardUserDefaults] floatForKey:@"gawkwall_album_contentOffset_y"]);
	[self.tableView setContentOffset:contentOffset];
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
	//cell.useDarkBackground = (indexPath.row % 2 == 0);
	UIImageView* vwimg = [ [ UIImageView alloc] initWithFrame: cell.frame];
	UIImage* img = [ UIImage imageNamed: @"cell-background"];
	vwimg.image = img;
	cell.backgroundView = vwimg;
	NSDictionary *dictionary = [self.tableDataSource objectAtIndex:indexPath.row];
	cell.wall = [dictionary objectForKey:@"RelatedWall"];
	cell.date = [dictionary objectForKey:@"DateCreated"];
	cell.icon = [UIImage imageWithContentsOfFile:[dictionary objectForKey:@"Thumbnail"]];
	cell.fav = ![[dictionary objectForKey:@"Fav"] boolValue] ? [UIImage imageNamed: @"fav-icon"] : [UIImage imageNamed:@"fav-icon-picked"];
	cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = ((ApplicationCell *)cell).useDarkBackground ? DARK_BACKGROUND : LIGHT_BACKGROUND;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	videoId = indexPath.row;
	
	NSLog(@"%d", videoId);
	NSDictionary *cellData = [self.tableDataSource objectAtIndex:videoId];
	wallName.text = [cellData objectForKey:@"RelatedWall"];
	NSURL *gawkPath = [[[NSURL alloc] initWithString:[cellData objectForKey:@"GawkUrl"]] autorelease];
//	[player play];
	[videoView removeFromSuperview];
	//[videoPlayer removeFromSuperview];
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	CGRect frame = videoPlayer.frame;
	frame.origin.y = 20.0;
	videoPlayer.frame = frame;
	[[[UIApplication sharedApplication] keyWindow] addSubview:videoPlayer];
	[self.tabBarController.tabBar setHidden:YES];
	[[[[UIApplication sharedApplication] keyWindow] layer] addAnimation:animation forKey:@"SwitchToView1"];
	[videoViewContainer addSubview:videoView];
	player =	[[MPMoviePlayerController alloc] initWithContentURL: gawkPath];
	//player.moviePlayer.repeatMode = MPMovieRepeatModeOne;
	//[self presentMoviePlayerViewControllerAnimated:player];
	player.repeatMode = MPMovieRepeatModeOne;
	player.movieSourceType = MPMovieSourceTypeFile;
	player.controlStyle = MPMovieControlStyleNone;
	player.scalingMode = MPMovieScalingModeAspectFill;
	[player.view setFrame: videoView.bounds];  // player's frame must match parent's
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
	[self.tabBarController.tabBar setHidden:NO];
	[self.tableView.superview addSubview:self.tableView];
	[[[[UIApplication sharedApplication] keyWindow] layer] addAnimation:animation forKey:@"SwitchBackToView0"];
		[videoPlayer removeFromSuperview];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if ([[self.tableView indexPathsForVisibleRows] count] > 0) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:([[[self.tableView indexPathsForVisibleRows] objectAtIndex:0] row] * self.tableView.rowHeight)] forKey:@"gawkwall_album_contentOffset_y"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (IBAction) favGawkItem {
	NSMutableArray *dataItems = [[[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] data] objectForKey:@"Rows"] mutableCopy];
	
	NSMutableDictionary *update = [[NSMutableDictionary alloc] initWithDictionary:[dataItems objectAtIndex:videoId]];	
	NSDictionary *member = [[NSDictionary alloc] initWithDictionary:[[[((GawkAppDelegate *)([UIApplication sharedApplication].delegate)) loginView] loginModel] member]];
	[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
	httpRequest  = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:GAWK_API_LOCAITON]];
	[httpRequest setPostValue:@"MemberRating.AddRating" forKey:@"Action"];
	[httpRequest setPostValue:[member objectForKey:@"token"] forKey:@"Token"];
	[httpRequest setPostValue:[update objectForKey:@"secureId"] forKey:@"VideoSecureId"];
	[httpRequest setPostValue:([[update valueForKey:@"Fav"] intValue] == 1) ? @"false" : @"true" forKey:@"PositiveRating"];
	[httpRequest setTimeOutSeconds:5];
	[httpRequest setDelegate:self];
	[httpRequest setDidFailSelector:@selector(favGawkFailed:)];
	[httpRequest setDidFinishSelector:@selector(favGawkFinished:)];
	[httpRequest startAsynchronous];
	[member release];
	NSLog(@"%d", [[update valueForKey:@"Fav"] intValue]);
	[update release];
	[self toggleFavStatus];
}

- (void) favGawkFailed:(ASIHTTPRequest *)request {
	[self onFavGawkError];
}

- (void) toggleFavStatus {
	
	NSMutableArray *dataItems = [[[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] data] objectForKey:@"Rows"] mutableCopy];
	
	NSMutableDictionary *update = [[NSMutableDictionary alloc] initWithDictionary:[dataItems objectAtIndex:videoId]];
	[update valueForKey:@"Fav"];
	[update setValue:[NSNumber numberWithBool:![[update objectForKey:@"Fav"] boolValue]] forKey:@"Fav"];
	[dataItems replaceObjectAtIndex:videoId withObject:update];
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	[data setObject:dataItems forKey:@"Rows"];
	[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] resetData:data];
	self.tableDataSource = [[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] data] objectForKey:@"Rows"];
	[self.tableView reloadData];
	[update release];
}

- (void) onFavGawkError {
	[self toggleFavStatus];
}

- (void) favGawkFinished:(ASIHTTPRequest *)request {
	NSString *responseData = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];
	SBJsonParser *parser = [SBJsonParser new];
  id object = [parser objectWithString:responseData];
  if (object) {
		if (![[object objectForKey:@"success"] boolValue]) {
			[self onFavGawkError];
			NSLog(@"%@", object);
		} else {
			
		}
		[self.tableView reloadData];
	} else {
		[self onFavGawkError];
		NSLog(@"%@", responseData);
	}
	[parser release];
}

@end
