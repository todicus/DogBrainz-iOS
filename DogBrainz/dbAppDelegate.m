//
//  dbAppDelegate.m
//  DogBrainz
//
//  Created by Tim O'Brien on 9/6/14.
//  Copyright (c) 2014 dogbrainzco. All rights reserved.
//

#import "dbAppDelegate.h"
#import "LGBluetooth.h"

LGPeripheral *collar;
LGService *scratchService;
LGCharacteristic *soundChar;
UInt16 soundNum = 0;

@implementation dbAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [self scanBLE];
    
    return YES;
}

- (void)scanBLE
{
    NSLog(@"start scan");
    // Scaning 4 seconds for peripherals
    [[LGCentralManager sharedInstance] scanForPeripheralsByInterval:2
                                                         completion:^(NSArray *peripherals)
     {
         if (peripherals.count) {
             for (int i=0; i<peripherals.count; i++) {
                 NSDictionary *adTable = [peripherals[i] advertisingData];
                 //if ([[peripherals[i] name]  isEqual: @"DogBrainz"]) {
                 if ([[adTable valueForKey: @"kCBAdvDataLocalName"] isEqual: @"DogBrainz"]) {
                     NSLog(@"found DogBrainz Collar");
                     collar = peripherals[i];
                     [self getSoundChar:collar];
                 }
             }
         }
     }];
}

// Gets the scratch service and sound characteristic.
- (void)getSoundChar:(LGPeripheral *)peripheral
{
    NSLog(@"looking for sound trigger characteristic");
    [peripheral connectWithCompletion:^(NSError *error) {
        // Discovering services of peripheral
        [peripheral discoverServicesWithCompletion:^(NSArray *services, NSError *error) {
            for (LGService *service in services) {
                // Finding out our service
                if ([service.UUIDString isEqualToString:serviceUUID]) {
                    scratchService = service;
                    
                    // Discover characteristics of the service
                    [service discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error){
                        for (LGCharacteristic *charact in characteristics) {
                            if ([charact.UUIDString isEqualToString:charUUID]) {
                                soundChar = charact;
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
