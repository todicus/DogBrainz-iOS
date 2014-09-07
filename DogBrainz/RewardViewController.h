//
//  dbFirstViewController.h
//  DogBrainz
//
//  Created by Tim O'Brien on 9/6/14.
//  Copyright (c) 2014 dogbrainzco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenSpatialBluetooth.h"

@interface RewardViewController : UIViewController<OpenSpatialBluetoothDelegate>

@property (strong,nonatomic) NSArray *gestures;
@property (strong,nonatomic) NSArray *sounds;
@property (weak, nonatomic) IBOutlet UIButton *starButton;
@property (weak, nonatomic) IBOutlet UIButton *gestureButton;
@property (weak, nonatomic) IBOutlet UIButton *soundButton;
@property (weak, nonatomic) IBOutlet UIButton *treatButton;

@property OpenSpatialBluetooth *HIDServ;
@property CBPeripheral *lastNodPeripheral;

@end
