//
//  SettingsViewController.h
//  DogBrainz
//
//  Created by Tim O'Brien on 9/7/14.
//  Copyright (c) 2014 dogbrainzco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *sparkDeviceIdField;
@property (weak, nonatomic) IBOutlet UITextField *sparkAccessTokenField;

@end
