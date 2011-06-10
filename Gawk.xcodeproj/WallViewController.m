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

- (void)getWallFailed:(ASIHTTPRequest *)request {
	
}

- (void)getWallFinished:(ASIHTTPRequest *)request {
	NSString *responseData = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];
	SBJsonParser *parser = [SBJsonParser new];
  id object = [parser objectWithString:responseData];
  if (object) {
		if (![[object objectForKey:@"success"] boolValue]) {
			NSLog(@"%@", responseData);
			[((GawkAppDelegate *)([UIApplication sharedApplication].delegate)) logout];
		} else {
			self.wallList = [NSArray arrayWithArray:[[object objectForKey:@"recentActivity"] objectForKey:@"wallsCreatedByMember"]];
		}
	} else {
	}
	[self.tableView reloadData];
	[parser release];
}

- (void)dealloc
{
	[wallList dealloc];
    [super dealloc];
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

- (void) getWall {
	
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
		[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
		httpRequest  = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:GAWK_API_LOCAITON]];
		[httpRequest setPostValue:@"MemberWallBookmark.GetRecentWallActivity" forKey:@"Action"];
		[httpRequest setPostValue:[[[[((GawkAppDelegate *)([UIApplication sharedApplication].delegate)) loginView] loginModel] member] objectForKey:@"token"] forKey:@"Token"];
		[httpRequest setTimeOutSeconds:5];
		[httpRequest setDelegate:self];
		[httpRequest setDidFailSelector:@selector(getWallFailed:)];
		[httpRequest setDidFinishSelector:@selector(getWallFinished:)];
		[httpRequest startAsynchronous];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tableView.rowHeight = 133.0; //Switch to 133.0
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
	cell.useDarkBackground = (indexPath.row % 2 == 0);
	
	NSDictionary *dictionary = [self.wallList objectAtIndex:indexPath.row];
	NSLog(@"%@", dictionary);
	cell.name = [dictionary objectForKey:@"name"];
	cell.creator = [dictionary objectForKey:@"memberSecureId"];
	cell.description = [dictionary objectForKey:@"description"];
	//cell.icon = [UIImage imageWithContentsOfFile:[dictionary objectForKey:@"Thumbnail"]];
	cell.accessoryType = UITableViewCellAccessoryNone;
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = ((WallCell *)cell).useDarkBackground ? DARK_BACKGROUND : LIGHT_BACKGROUND;
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
	if ([delegate respondsToSelector:@selector(onCellSelect:)]) {
		[delegate onCellSelect:[dictionary objectForKey:@"secureId"]];
	}
}

@end
