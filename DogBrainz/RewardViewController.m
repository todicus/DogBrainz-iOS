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
@end

@implementation RewardViewController

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
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@", TREAT_URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"access_token" forHTTPHeaderField:TREAT_ACCESS_TOKEN];
    NSString *postString = @"args=dispense";
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSError *error;
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"post results: %@, %@, %@", data, response, error);
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


@end
