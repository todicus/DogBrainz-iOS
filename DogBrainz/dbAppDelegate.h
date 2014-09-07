//
//  dbAppDelegate.h
//  DogBrainz
//
//  Created by Tim O'Brien on 9/6/14.
//  Copyright (c) 2014 dogbrainzco. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString *serviceUUID   = @"a495ff20-c5b1-4b44-b512-1370f02d74de"; 	// Bean scratch service
NSString *charUUID      = @"a495ff22-c5b1-4b44-b512-1370f02d74de"; 	// Bean characteristic I'm using,2 out of 5

@interface dbAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
