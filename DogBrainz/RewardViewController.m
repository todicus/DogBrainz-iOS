//
//  dbFirstViewController.m
//  DogBrainz
//
//  Created by Tim O'Brien on 9/6/14.
//  Copyright (c) 2014 dogbrainzco. All rights reserved.
//

#import "RewardViewController.h"
#import "ActionSheetStringPicker.h"
#import "BrainzDelegate.h"


@interface RewardViewController ()
@property int gestureIndex, soundIndex;
//@property OpenSpatialBluetooth *nod;
@end

@implementation RewardViewController

uint8_t mode = POINTER_MODE;
BrainzConnectedCallback connectedCallback;


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.gestures = @[@"ccw",@"cw",@"up",@"down",@"left",@"right"];
    self.sounds = @[@"chick",@"whistle",@"clicker", @"bell", @"bird", @"bike", @"coin", @"aayeah"];

    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    self.gestureIndex = [preferences integerForKey:@"gestureIndex"];
    self.soundIndex = [preferences integerForKey:@"soundIndex"];
    [self updateLables];
    [self.starButton setTintColor:disabledColorApp];
    [self.treatButton setTintColor:disabledColorApp];
    connectedCallback = ^(LGCharacteristic *soundCharacteristic) {
        [self.starButton setTintColor:highlightColorApp];
        [self.treatButton setTintColor:highlightColorApp];
    };

    [BrainzDelegate getBLEDeviceWithCallback:connectedCallback];
}


- (void)updateLables {
    [self.gestureButton setTitle:self.gestures[self.gestureIndex] forState: UIControlStateNormal];
    [self.soundButton setTitle:self.sounds[self.soundIndex] forState: UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickTreat:(id)sender {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString *sparkDeviceId = [preferences stringForKey:@"sparkDeviceId"];
    NSString *sparkAccessToken = [preferences stringForKey:@"sparkAccessToken"];
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:TREAT_BASE_URL, sparkDeviceId]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", sparkAccessToken] forHTTPHeaderField:@"Authorization"];
    NSString *postString = @"{\"args\":\"dispense\"}";
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"posting: %@, %@", request, [request HTTPMethod]);
    NSError *error;
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"post results: %@, %@, %@", [NSString stringWithUTF8String:data.bytes], response, error);
}

- (IBAction)clickNod:(id)sender {
    //setup NOD gesture ring device
    self.nod = [OpenSpatialBluetooth sharedBluetoothServ];
    [self.nod setDelegate:self];
    [self.nod scanForPeripherals];
}

- (IBAction)clickPlaySound:(id)sender {
    NSLog(@"yo, got clicked on play sound");
    LGCharacteristic *device = [BrainzDelegate getBLEDeviceWithCallback:connectedCallback];
    if (device) {
        NSData *toWrite = [NSData dataWithBytes:(unsigned char[]){0x63, self.soundIndex} length:2];
        NSLog(@"%@", toWrite);
        [device writeValue:toWrite completion:^(NSError *error) {
            if (error) NSLog(@"uh oh: %@", error);
        }];
    } else NSLog(@"not connected, can't send");
}

- (IBAction)chooseGesture:(id)sender {
    [ActionSheetStringPicker showPickerWithTitle: @"Select a Gesture"
                                            rows: self.gestures
                                initialSelection: self.gestureIndex
                                       doneBlock: ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           self.gestureIndex = selectedIndex;
                                           NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
                                           [preferences setInteger: self.gestureIndex forKey:@"gestureIndex"];
                                           [preferences synchronize];
                                           [self updateLables];
                                       }
                                     cancelBlock: nil
                                          origin: sender];
}

- (IBAction)chooseSound:(id)sender {
    [ActionSheetStringPicker showPickerWithTitle: @"Select a Sound"
                                            rows: self.sounds
                                initialSelection: self.soundIndex
                                       doneBlock: ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           self.soundIndex = selectedIndex;
                                           NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
                                           [preferences setInteger: self.soundIndex forKey:@"soundIndex"];
                                           [preferences synchronize];
                                           [self updateLables];
                                       }
                                     cancelBlock: nil
                                          origin: sender];
}


/* --- NOD gesture ring protocol methods --- */

-(void) startLoop {
    NSLog(@"NOD LOOP");
    
    if ([self.nod isSubscribedToEvent:@"GESTURE" forPeripheral:self.lastNodPeripheral.name]) {
        NSLog(@"connected to gesture");
        [self.nodButton setTintColor:highlightColorApp];
    } else {
        [self.nodButton setTintColor:disabledColorApp];
    }
    NSLog(@"have: %@", [self.nod.connectedPeripherals allKeys]);
    
    [self performSelector:@selector(startLoop) withObject:nil afterDelay:5];
}

- (void)didFindNewDevice:(CBPeripheral*) peripheral {
    for (int i=0; i<[self.nod.foundPeripherals count]; i++) {
        CBPeripheral *newPeripheral = self.nod.foundPeripherals[i];
        NSLog(@"FOUND: %@", newPeripheral.name);
        if([newPeripheral.name isEqualToString:@"nod-04"]) {
            [self.nod connectToPeripheral:newPeripheral];
        }
    }
}

- (void) didConnectToNod: (CBPeripheral*) peripheral {
    NSLog(@"NOD CONNECTED");
    self.lastNodPeripheral = peripheral;
    [self.nodButton setTintColor:highlightColorApp];
    
    

    
    [self.nod subscribeToPointerEvents:self.lastNodPeripheral.name];
    [self.nod subscribeToGestureEvents:peripheral.name];
    NSLog(@"connected to gesture: %s", [self.nod isSubscribedToEvent:@"GESTURE" forPeripheral:self.lastNodPeripheral.name] ? "true" : "false");

    //[self.nod setMode:THREE_D_MODE forDeviceNamed:self.lastNodPeripheral.name]; // crashes
    
    [self startLoop];
}

-(GestureEvent *)gestureEventFired: (GestureEvent *) gestureEvent {
    NSLog(@"This is the value of gesture event type from %@", [gestureEvent.peripheral name]);
    switch([gestureEvent getGestureEventType])
    {
        case SWIPE_UP:
            NSLog(@"Gesture Up");
            break;
        case SWIPE_DOWN:
            NSLog(@"Gesture Down");
            break;
        case SWIPE_LEFT:
            NSLog(@"Gesture Left");
            break;
        case SWIPE_RIGHT:
            NSLog(@"Gesture Right");
            break;
        case SLIDER_LEFT:
            NSLog(@"Slider Left");
            break;
        case SLIDER_RIGHT:
            NSLog(@"Slider Right");
            break;
        case CCW:
            NSLog(@"Counter Clockwise");
            break;
        case CW:
            NSLog(@"Clockwise");
            break;
    }
    
    return nil;
}

-(ButtonEvent *)buttonEventFired: (ButtonEvent *) buttonEvent { return nil; }
-(PointerEvent *)pointerEventFired: (PointerEvent *) pointerEvent { return nil; }
-(RotationEvent *)rotationEventFired: (RotationEvent *) rotationEvent { return nil; }





@end
