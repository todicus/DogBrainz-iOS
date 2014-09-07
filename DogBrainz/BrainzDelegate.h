//
//  dbAppDelegate.h
//  DogBrainz
//
//  Created by Tim O'Brien on 9/6/14.
//  Copyright (c) 2014 dogbrainzco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGCharacteristic.h"

@interface BrainzDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


typedef void (^BrainzConnectedCallback) (LGCharacteristic *soundCharacteristic);

+ (LGCharacteristic *)getBLEDeviceWithCallback:(BrainzConnectedCallback) myCallback;

@end


