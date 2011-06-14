//
//  SettingsViewController.m
//  Gawk
//
//  Created by Tom Gallacher on 31/05/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import "SettingsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GawkAppDelegate.h"

@implementation SettingsViewController
@synthesize member;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
	[member release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)gotoLink:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: url.titleLabel.text]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	if (member == nil) {
		member = [[NSDictionary alloc] initWithDictionary:[[[((GawkAppDelegate *)([UIApplication sharedApplication].delegate)) loginView] loginModel] member]];
	}
    // Do any additional setup after loading the view from its nib.
	[profileImage.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
	[profileImage.layer setBorderWidth:1.0];
	userName.text = [member objectForKey:@"alias"];
	fullName.text = [NSString stringWithFormat:@"%@ %@", [member objectForKey:@"firstName"], [member objectForKey:@"lastName"]];
	url.titleLabel.text = [member objectForKey:@"website"];
	description.text = [member objectForKey:@"description"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	profileImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://salt.gawkwall.com/u/%@/profile/img/70x60", [member objectForKey:@"alias"]]] options:NSDataReadingMapped error:nil]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) logout:(id)sender {
	[((GawkAppDelegate *)([UIApplication sharedApplication].delegate)) logout];
}

@end
