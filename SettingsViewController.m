//
//  SettingsViewController.m
//  Gawk
//
//  Created by Tom Gallacher on 31/05/2011.
//  Copyright 2011 Clock Ltd. All rights reserved.
//

#import "SettingsViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
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
    // Do any additional setup after loading the view from its nib.
	[profileImage.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
	[profileImage.layer setBorderWidth:1.0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
