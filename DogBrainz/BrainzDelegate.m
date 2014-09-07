//
//  dbAppDelegate.m
//  DogBrainz
//
//  Created by Tim O'Brien on 9/6/14.
//  Copyright (c) 2014 dogbrainzco. All rights reserved.
//

#import "BrainzDelegate.h"
#import "LGBluetooth.h"

@interface BrainzDelegate ()

@property LGPeripheral *connectedPeripheral;
@property LGService *scratchService;
@property LGCharacteristic *soundCharacteristic;
@property UInt16 soundNum;
@end

//Constants
NSString *serviceUUID        = @"a495ff20-c5b1-4b44-b512-1370f02d74de"; // Bean scratch service
NSString *characteristicUUID = @"a495ff22-c5b1-4b44-b512-1370f02d74de"; // Bean characteristic I'm using 2 out of 5
const NSString *bleDeviceName      = @"DogBrainz";


@implementation BrainzDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

+ (LGCharacteristic *)getBLEDeviceWithCallback:(BrainzConnectedCallback) myCallback
{
    BrainzDelegate *app = [[UIApplication sharedApplication] delegate];
    if ((app.connectedPeripheral != nil) && (app.scratchService != nil)) {
        return app.soundCharacteristic;
    } else {
        [app connectToBLEDeviceWithCallback: myCallback];
        return nil;
    }
}

- (void)connectToBLEDeviceWithCallback:(BrainzConnectedCallback) mycallback
{
    NSLog(@"start scan");
    // Scaning 4 seconds for peripherals
    [[LGCentralManager sharedInstance] scanForPeripheralsByInterval:2 completion:
     ^(NSArray *peripherals) {
         NSLog(@"finish scan with: %@", peripherals);
         if (peripherals.count) {
             for (int i=0; i<peripherals.count; i++) {
                 NSDictionary *adTable = [peripherals[i] advertisingData];
                 if ([[adTable valueForKey: @"kCBAdvDataLocalName"] isEqual: bleDeviceName]) {
                     NSLog(@"found periph: %@", peripherals[i]);
                     self.connectedPeripheral = peripherals[i];
                     [self getBleDeviceServiceCharacteristicWithCallback: mycallback];
                 }
             }
         }
     }];
}

// Gets the scratch service and sound characteristic.
- (void)getBleDeviceServiceCharacteristicWithCallback:(BrainzConnectedCallback) mycallback
{
    NSLog(@"looking for sound trigger characteristic");
    [self.connectedPeripheral connectWithCompletion:^(NSError *error) {
        // Discovering services of peripheral
        NSLog(@"finished connect with: %@", error);
        [self.connectedPeripheral discoverServicesWithCompletion:^(NSArray *services, NSError *error) {
            NSLog(@"finished discover with: %@ and error: %@", services, error);
            for (LGService *service in services) {
                // Finding out our service
                if ([service.UUIDString isEqualToString:serviceUUID]) {
                    NSLog(@"found service with: %@", service);
                    self.scratchService = service;
                    // Discover characteristics of the service
                    [service discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error){
                        NSLog(@"found characteristics with: %@ and error: %@", characteristics, error);
                        for (LGCharacteristic *charact in characteristics) {
                            if ([charact.UUIDString isEqualToString:characteristicUUID]) {
                                NSLog(@"WOO found matching characteristics with: %@", charact);
                                self.soundCharacteristic = charact;
                                mycallback(self.soundCharacteristic);
                            }
                        }
                    }];
                }
            }
        }];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
