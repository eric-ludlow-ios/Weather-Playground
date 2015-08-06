//
//  WPViewController.m
//  Weather Playground
//
//  Created by Joshua Howland on 6/17/14.
//  Copyright (c) 2014 DevMountain. All rights reserved.
//

#import "WPViewController.h"

@interface WPViewController ()

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentConditionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *todayHighTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *todayConditionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *tomorrowHighTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *tomorrowConditionsLabel;

@end

@implementation WPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)searchButtonPressed:(id)sender {
    
    NSString *searchText = self.searchTextField.text;
    
    NSString *searchTerm = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *searchURL = [NSURL URLWithString:
                        [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@&units=imperial", searchTerm]];
    
    NSURL *forecastURL = [NSURL URLWithString:
                          [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?q=%@&cnt=2&units=imperial", searchTerm]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithURL:searchURL
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                       
                                                       NSError *jsonError;
                                                       
                                                       NSDictionary *serializedResults = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                         options:NSJSONReadingAllowFragments
                                                                                                                           error:&jsonError];
                                                       
                                                       if (error) {
                                                           NSLog(@"Session Data Task Error: %@", error);
                                                       } else if (jsonError){
                                                           NSLog(@"JSON Error: %@", jsonError);
                                                       } else {
                                                           NSLog(@"no errors");
                                                       }
                                                       
                                                       double currentTempResult = ((NSNumber *)(serializedResults[@"main"][@"temp"])).doubleValue;
                                                       NSString *currentTempString = [NSString stringWithFormat:@"%.2f°F", currentTempResult];
                                                       
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           
                                                           self.searchTextField.text = @"";
                                                           self.cityNameLabel.text = serializedResults[@"name"];
                                                           self.currentTempLabel.text = currentTempString;
                                                           self.currentConditionsLabel.text = serializedResults[@"weather"][0][@"description"];
                                                       });
                                                   }];
    
    NSURLSessionDataTask *sessionForecastDataTask = [session dataTaskWithURL:forecastURL
                                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                               NSError *jsonError;
                                                               
                                                               NSDictionary *serializedResults = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                 options:NSJSONReadingAllowFragments
                                                                                                                                   error:&jsonError];
                                                               if (error) {
                                                                   NSLog(@"Session Data Task Error: %@", error);
                                                               } else if (jsonError) {
                                                                   NSLog(@"JSON Error: %@", jsonError);
                                                               } else {
                                                                   NSLog(@"no errors");
                                                               }
                                                               
                                                               double highTempResult = ((NSNumber *)(serializedResults[@"list"][0][@"temp"][@"max"])).doubleValue;
                                                               NSString *highTempString = [NSString stringWithFormat:@"%.2f°F", highTempResult];
                                                               
                                                               double tomorrowHighTemp = ((NSNumber *)(serializedResults[@"list"][1][@"temp"][@"max"])).doubleValue;
                                                               NSString *tomorrowHighTempString = [NSString stringWithFormat:@"%.2f°F", tomorrowHighTemp];
                                                               
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   
                                                                   self.todayHighTempLabel.text = highTempString;
                                                                   self.todayConditionsLabel.text = serializedResults[@"list"][0][@"weather"][0][@"description"];
                                                                   
                                                                   self.tomorrowHighTempLabel.text = tomorrowHighTempString;
                                                                   self.tomorrowConditionsLabel.text = serializedResults[@"list"][1][@"weather"][0][@"description"];
                                                                   
                                                               });
                                                           }];
    
    [sessionDataTask resume];
    [sessionForecastDataTask resume];
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
