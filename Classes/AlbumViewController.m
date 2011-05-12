//
//  AlbumViewController.m
//  Gawk
//
//  Created by Tom Gallacher on 10/05/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import "AlbumViewController.h"
#import "GawkAppDelegate.h"

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
	NSLog(@"%@", self.tableDataSource);

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
	cell.date = @"Date 10/01/2001";
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = ((ApplicationCell *)cell).useDarkBackground ? DARK_BACKGROUND : LIGHT_BACKGROUND;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
