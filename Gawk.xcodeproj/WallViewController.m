//
//  WallViewController.m
//  Gawk
//
//  Created by Tom Gallacher on 23/05/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import "WallViewController.h"
#import "ASIFormDataRequest.h"
#import "GawkAppDelegate.h"
#import "JSON.h"
#import "SHK.h"
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import <MediaPlayer/MPMoviePlayerController.h>

#define DARK_BACKGROUND  [UIColor colorWithRed:151.0/255.0 green:152.0/255.0 blue:155.0/255.0 alpha:1.0]
#define LIGHT_BACKGROUND [UIColor colorWithRed:172.0/255.0 green:173.0/255.0 blue:175.0/255.0 alpha:1.0]

@interface WallViewController ()
- (void)getWallFailed:(ASIHTTPRequest *)request;
- (void)getWallFinished:(ASIHTTPRequest *)request;
@end

@implementation WallViewController
@synthesize wallList, tmpCell;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) receiveReloadWallNotification: (NSNotification *) notification {	
	if ([[notification name] isEqualToString:@"ReloadWallView"]) {
		[self getWalls];
	}
}

- (void)getWallFailed:(ASIHTTPRequest *)request {
	
}

- (void)getWallFinished:(ASIHTTPRequest *)request {
	NSString *responseData = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];
	SBJsonParser *parser = [SBJsonParser new];
  id object = [parser objectWithString:responseData];
  if (object) {
		if (![[object objectForKey:@"success"] boolValue]) {
			[((GawkAppDelegate *)([UIApplication sharedApplication].delegate)) logout];
		} else {
			self.wallList = [NSArray arrayWithArray:[[object objectForKey:@"recentActivity"] objectForKey:@"wallsCreatedByMember"]];
			[(GawkAppDelegate *)[[UIApplication sharedApplication] delegate] updateWalls:[NSMutableArray arrayWithArray:self.wallList]];
		}
		[self.tableView reloadData];
	} else {
	}
	[parser release];
	CGPoint contentOffset = CGPointMake(0,[[NSUserDefaults standardUserDefaults] floatForKey:@"gawkwall_wall_contentOffset_y"]);
	[self.tableView setContentOffset:contentOffset];
}

- (void)dealloc
{
	[wallList dealloc];
    [super dealloc];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSDictionary *)getMember {
	return [[[((GawkAppDelegate *)([UIApplication sharedApplication].delegate)) loginView] loginModel] member];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction) getWalls {
	[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
	httpRequest  = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:GAWK_API_LOCAITON]];
	[httpRequest setPostValue:@"MemberWallBookmark.GetRecentWallActivity" forKey:@"Action"];
	[httpRequest setPostValue:[[[[((GawkAppDelegate *)([UIApplication sharedApplication].delegate)) loginView] loginModel] member] objectForKey:@"token"] forKey:@"Token"];
	[httpRequest setTimeOutSeconds:5];
	[httpRequest setDelegate:self];
	[httpRequest setDidFailSelector:@selector(getWallFailed:)];
	[httpRequest setDidFinishSelector:@selector(getWallFinished:)];
	[httpRequest startAsynchronous];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.wallList = [NSArray arrayWithArray:[((GawkAppDelegate *)([UIApplication sharedApplication].delegate)) walls]];
	if ([self.wallList count] == 0) {
		[self getWalls];
	} else {
		CGPoint contentOffset = CGPointMake(0,[[NSUserDefaults standardUserDefaults] floatForKey:@"gawkwall_wall_contentOffset_y"]);
		[self.tableView setContentOffset:contentOffset];
	}
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tableView.rowHeight = 133.0; //Switch to 133.0
	self.tableView.backgroundColor = LIGHT_BACKGROUND;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.scrollsToTop = YES;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveReloadWallNotification:) name:@"ReloadWallView" object:nil];
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
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.tableView.contentOffset.y] forKey:@"gawkwall_wall_contentOffset_y"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (!wallList) {
		return 0;
	} else {
    return [self.wallList count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"WallCell";
	
	WallCell *cell = (WallCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"WallCellSubView" owner:self options:nil];
		cell = tmpCell;
		self.tmpCell = nil;
		
	}
	
	// Display dark and light background in alternate rows -- see tableView:willDisplayCell:forRowAtIndexPath:.
	//cell.useDarkBackground = (indexPath.row % 2 == 0);
	UIImageView* vwimg = [ [ UIImageView alloc] initWithFrame: cell.frame];
	UIImage* img = [ UIImage imageNamed: @"cell-background"];
	vwimg.image = img;
	cell.backgroundView = vwimg;
	NSDictionary *dictionary = [self.wallList objectAtIndex:indexPath.row];
	cell.name = [dictionary objectForKey:@"name"];
	cell.creator = [dictionary objectForKey:@"memberSecureId"];
	cell.description = [dictionary objectForKey:@"description"];
	//cell.icon = [UIImage imageWithContentsOfFile:[dictionary objectForKey:@"Thumbnail"]];
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.backgroundColor = [UIColor clearColor];
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	//cell.backgroundColor = ((WallCell *)cell).useDarkBackground ? DARK_BACKGROUND : LIGHT_BACKGROUND;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
	NSDictionary *dictionary = [wallList objectAtIndex:indexPath.row];
	id delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(onCellSelect::)]) {
		[delegate onCellSelect:[dictionary objectForKey:@"secureId"]:[dictionary objectForKey:@"name"]];
	}
}

- (IBAction) viewGawks:(id) sender {
	NSString *url = [[NSBundle mainBundle] pathForResource:@"stitch" ofType:@"mp4"];	
	MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:url]];
	[[player moviePlayer] setRepeatMode:MPMovieRepeatModeOne];
	[[((GawkAppDelegate *)([UIApplication sharedApplication].delegate)) tabBarController] presentMoviePlayerViewControllerAnimated:player];	
}

- (IBAction) recordGawk:(id) sender {
	UIView *senderButton = (UIView*) sender;
	NSIndexPath *indexPath = [self.tableView indexPathForCell: (UITableViewCell*)[[senderButton superview]superview]];
	NSDictionary *dictionary = [wallList objectAtIndex:indexPath.row];
	id delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(onCellSelect::)]) {
		[delegate onCellSelect:[dictionary objectForKey:@"secureId"]:[dictionary objectForKey:@"name"]];
	}
}

-(IBAction)shareGawkwall:(id)sender {
	UIView *senderButton = (UIView*) sender;
	NSIndexPath *indexPath = [self.tableView indexPathForCell: (UITableViewCell*)[[senderButton superview]superview]];
	NSDictionary *dictionary = [wallList objectAtIndex:indexPath.row];
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@%@", GAWK_URL, [dictionary objectForKey:@"url"]];
	NSURL *url = [NSURL URLWithString:urlString];
	[urlString release];
	
	SHKItem *item = [SHKItem URL:url title:@"Check out my Gawkwall!"];
	
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	
	// Display the action sheet
	[actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:([[[self.tableView indexPathsForVisibleRows] objectAtIndex:0] row] * self.tableView.rowHeight)] forKey:@"gawkwall_wall_contentOffset_y"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
