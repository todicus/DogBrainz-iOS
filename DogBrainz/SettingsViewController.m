//
//  SettingsViewController.m
//  DogBrainz
//
//  Created by Tim O'Brien on 9/7/14.
//  Copyright (c) 2014 dogbrainzco. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    self.sparkDeviceIdField.text = [preferences stringForKey:@"sparkDeviceId"];
    self.sparkAccessTokenField.text = [preferences stringForKey:@"sparkAccessToken"];
}

- (IBAction)setSparkDeviceID:(id)sender {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences setValue:self.sparkDeviceIdField.text forKey:@"sparkDeviceId"];
    [preferences synchronize];
    [self.sparkDeviceIdField resignFirstResponder];
}
- (IBAction)setSparkAccessToken:(id)sender {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences setValue:self.sparkAccessTokenField.text forKey:@"sparkAccessToken"];
    [preferences synchronize];
    [self.sparkAccessTokenField resignFirstResponder];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
