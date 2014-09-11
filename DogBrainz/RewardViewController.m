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

uint8_t mode = POINTER_MODE; //THREE_D_MODE
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

    // connect to collar on load
    //[BrainzDelegate getBLEDeviceWithCallback:connectedCallback];
    [self clickNod:nil];
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

// Whay is this for?
-(void) startLoop {
    /*NSLog(@"NOD LOOP");
    
    if ([self.nod isSubscribedToEvent:@"GESTURE" forPeripheral:self.lastNodPeripheral.name]) {
        NSLog(@"connected to gesture");
        [self.nodButton setTintColor:highlightColorApp];
    } else {
        [self.nodButton setTintColor:disabledColorApp];
    }
    NSLog(@"have: %@", [self.nod.connectedPeripherals allKeys]);
    */
    [self performSelector:@selector(startLoop) withObject:nil afterDelay:5];
}

- (void)didFindNewDevice:(CBPeripheral*) peripheral {
    NSLog(@"Looking for Nod:");
    for (int i=0; i<[self.nod.foundPeripherals count]; i++) {
        CBPeripheral *newPeripheral = self.nod.foundPeripherals[i];
        NSLog(@"Found: %@", newPeripheral.name);
        if([newPeripheral.name isEqualToString:@"nod-04"]) {
            [self.nod connectToPeripheral:newPeripheral];
        }
    }
}

- (void) didConnectToNod: (CBPeripheral*) peripheral {
    NSLog(@"NOD CONNECTED");
    self.lastNodPeripheral = peripheral;
    [self.nodButton setTintColor:highlightColorApp];
    
    [self.nod setMode:mode forDeviceNamed:self.lastNodPeripheral.name];
    
    [self.nod subscribeToGestureEvents:peripheral.name];
    [self.nod subscribeToButtonEvents:self.lastNodPeripheral.name];
    [self.nod subscribeToPointerEvents:self.lastNodPeripheral.name];
    [self.nod subscribeToRotationEvents:self.lastNodPeripheral.name];
    
    NSLog(@"connected to gesture: %s", [self.nod isSubscribedToEvent:@"GESTURE" forPeripheral:self.lastNodPeripheral.name] ? "true" : "false");
    
    [self startLoop];
}

-(GestureEvent *)gestureEventFired: (GestureEvent *) gestureEvent {
    //NSLog(@"This is the value of gesture event type from %@", [gestureEvent.peripheral name]);
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

-(ButtonEvent *)buttonEventFired: (ButtonEvent *) buttonEvent
{
    //NSLog(@"This is the value of button event type from %@", [buttonEvent.peripheral name]);
    switch([buttonEvent getButtonEventType])
    {
        case TOUCH0_DOWN:
            NSLog(@"Touch 0 Down");
            break;
        case TOUCH0_UP:
            NSLog(@"Touch 0 Up");
            break;
        case TOUCH1_DOWN:
            NSLog(@"Touch 1 Down");
            break;
        case TOUCH1_UP:
            NSLog(@"Touch 1 Up");
            break;
        case TOUCH2_DOWN:
            NSLog(@"Touch 2 Down");
            break;
        case TOUCH2_UP:
            NSLog(@"Touch 2 Up");
            break;
        case TACTILE0_DOWN:
            NSLog(@"Tactile 0 Down");
            break;
        case TACTILE0_UP:
            NSLog(@"Tactile 0 Up");
            break;
        case TACTILE1_DOWN:
            NSLog(@"Tactile 1 Down");
            break;
        case TACTILE1_UP:
            NSLog(@"Tactile 1 Up");
            break;
    }
    
    return nil;
}

-(PointerEvent *)pointerEventFired: (PointerEvent *) pointerEvent
{
    
    //NSLog(@"This is the x value of the pointer event from %@", [pointerEvent.peripheral name]);
    NSLog(@"%hd, %hd", [pointerEvent getXValue], [pointerEvent getYValue]);
    
    
    //NSLog(@"This is the y value of the pointer event from %@", [pointerEvent.peripheral name]);
    
    return nil;
}

-(RotationEvent *)rotationEventFired:(RotationEvent *)rotationEvent
{
    //NSLog(@"This is the x value of the quaternion from %@", [rotationEvent.peripheral name]);
    //NSLog(@"%f %f %f", rotationEvent.x, rotationEvent.y, rotationEvent.z);    //TA nothing in xyz
    
    //NSLog(@"This is the roll value of the quaternion from %@", [rotationEvent.peripheral name]);
    NSLog(@"%f %f %f", rotationEvent.roll, rotationEvent.pitch, rotationEvent.yaw);
    
    return nil;
}


@end
