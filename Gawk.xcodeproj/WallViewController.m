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

@interface WallViewController ()
- (void)getWallFailed:(ASIHTTPRequest *)request;
- (void)getWallFinished:(ASIHTTPRequest *)request;
@end

@implementation WallViewController
@synthesize wallList;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
	wallList = [[NSMutableArray alloc] init];
}

- (void)getWallFailed:(ASIHTTPRequest *)request {
	
}

- (void)getWallFinished:(ASIHTTPRequest *)request {
	NSString *responseData = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];
	SBJsonParser *parser = [SBJsonParser new];
  id object = [parser objectWithString:responseData];
  if (object) {
		[wallList release];
		wallList = [[NSMutableArray alloc] initWithArray:[[object objectForKey:@"recentActivity"] objectForKey:@"wallsCreatedByMember"]];
	} else {
	}
	[self.tableView reloadData];
	[parser release];
}

- (void)dealloc
{
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
		NSDictionary *member = [[NSDictionary alloc] initWithDictionary:[self getMember]];
		NSLog(@"NBOM%@", [member objectForKey:@"token"]);
		
		[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
		httpRequest  = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:GAWK_API_LOCAITON]];
		[httpRequest setPostValue:@"MemberWallBookmark.GetRecentWallActivity" forKey:@"Action"];
		[httpRequest setPostValue:[member objectForKey:@"token"] forKey:@"Token"];
		[httpRequest setTimeOutSeconds:5];
		[httpRequest setDelegate:self];
		[httpRequest setDidFailSelector:@selector(getWallFailed:)];
		[httpRequest setDidFinishSelector:@selector(getWallFinished:)];
		[httpRequest startAsynchronous];
		[member release];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (!wallList) {
		return 0;
	} else {
		//NSLog(@"%@", [wallList ]);
    return [wallList count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	NSDictionary *dictionary = [self.wallList objectAtIndex:indexPath.row];
    cell.textLabel.text = [dictionary objectForKey:@"name"];
    // Configure the cell...
    
    return cell;
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
	NSDictionary *dictionary = [self.wallList objectAtIndex:indexPath.row];
	id delegate = [self delegate];
	if ([delegate respondsToSelector:@selector(onCellSelect:)]) {
		[delegate onCellSelect:[dictionary objectForKey:@"secureId"]];
	}
}

@end
