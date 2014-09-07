//
//  dbFirstViewController.m
//  DogBrainz
//
//  Created by Tim O'Brien on 9/6/14.
//  Copyright (c) 2014 dogbrainzco. All rights reserved.
//

#import "RewardViewController.h"

@interface RewardViewController ()

@end

@implementation RewardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.gestures = @[@"one",@"two",@"three",@"four"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickPlaySound:(id)sender {
    NSLog(@"yo, got clicked on play sound");
}

- (IBAction)chooseGesture:(id)sender {
    NSLog(@"yo, got clicked on gesture");
    UIPickerView *picker = [[UIPickerView alloc] init];
    picker.dataSource = self;
    picker.delegate = self;
    [picker becomeFirstResponder];
}

- (IBAction)chooseSound:(id)sender {
    NSLog(@"yo, got clicked on sound");
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.gestures.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.gestures[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"chose value! %i = %@",row, self.gestures[row]);
}


@end
