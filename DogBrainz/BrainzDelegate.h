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
+ (void)reconnectBLE:(BrainzConnectedCallback) myCallback;

@end


#define highlightColorApp [UIColor colorWithRed:1.0 green:149.0/255.0 blue:0.0 alpha:1.0]
#define disabledColorApp [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0]

#define TREAT_BASE_URL @"https://api.spark.io/v1/devices/%@/treat"

