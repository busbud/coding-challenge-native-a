//
//  HomeViewController.m
//  BusBud
//
//  Created by Chris Comeau on 2014-11-02.
//  Copyright (c) 2014 Skyriser Media. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()
@property (nonatomic, strong) IBOutlet UILabel *versionLabel;
@property (nonatomic, strong) IBOutlet UIButton *fromButton;
@property (nonatomic, strong) IBOutlet UIButton *toButton;
@property (nonatomic, strong) IBOutlet UIButton *searchButton;

@property (nonatomic, strong) NSString *fromString;
@property (nonatomic, strong) NSString *toString;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //navbar
    UIButton *logoButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,97,28)];
    [logoButton setTitle:@"" forState:UIControlStateNormal];
    [logoButton setBackgroundColor:[UIColor clearColor]];
    [logoButton setImage:[UIImage imageNamed:@"nav_logo.png"] forState:UIControlStateNormal];
    logoButton.userInteractionEnabled = NO;
    self.navigationItem.titleView = logoButton;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = kColorBlue;
    self.navigationController.navigationBar.backgroundColor = kColorBlue;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    //version
    self.versionLabel.text = [NSString stringWithFormat:@"%@ %@ (%@) - Chris Comeau",
                            NSLocalizedString(@"kVersion", nil),
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    
    self.versionLabel.font = [UIFont fontWithName:@"AshemoreSoftCondMedium" size:12];
    self.versionLabel.textAlignment = NSTextAlignmentLeft;
    self.versionLabel.textColor = [UIColor whiteColor];;
    self.versionLabel.alpha = 0.4f;
    
    
    //buttons
    [self.fromButton setTitle:NSLocalizedString(@"kFromButton", nil) forState:UIControlStateNormal];
    self.fromButton.titleLabel.font = [UIFont fontWithName:@"AshemoreSoftCondMedium" size:14];
    self.fromButton.titleEdgeInsets = UIEdgeInsetsMake(0, kButtonTitleOffset, 0, 0);

    [self.toButton setTitle:NSLocalizedString(@"kToButton", nil) forState:UIControlStateNormal];
    self.toButton.titleLabel.font = [UIFont fontWithName:@"AshemoreSoftCondMedium" size:14];
    self.toButton.titleEdgeInsets = UIEdgeInsetsMake(0, kButtonTitleOffset, 0, 0);

    [self.searchButton setTitle:NSLocalizedString(@"kSearchButton", nil) forState:UIControlStateNormal];
    self.searchButton.titleLabel.font = [UIFont fontWithName:@"AshemoreSoftCondMedium" size:14];
    self.searchButton.titleEdgeInsets = UIEdgeInsetsMake(0, kButtonTitleOffset, 0, 0);

    
    [self updateUI];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - UI

- (void)updateUI {
    
    //color based on valid locations
    
    if(self.fromString) {
        [self.fromButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else {
        [self.fromButton setTitleColor:kColorPlaceholder forState:UIControlStateNormal];
    }

        
    if(self.toString) {
        [self.toButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else {
        [self.toButton setTitleColor:kColorPlaceholder forState:UIControlStateNormal];
    }
    
    
    [self.searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    /*if(self.toString && self.toString) {
        [self.searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    else {
        
        [self.searchButton setTitleColor:kColorPlaceholder forState:UIControlStateNormal];
    }*/

}


#pragma mark -
#pragma mark - Actions


- (IBAction)actionFrom:(id)sender {
    [self performSegueWithIdentifier:@"city" sender:nil];
}

- (IBAction)actionTo:(id)sender {
    [self performSegueWithIdentifier:@"city" sender:nil];
    
}

- (IBAction)actionSearch:(id)sender {

    //valid locations
    if(self.toString && self.toString) {
        [self performSegueWithIdentifier:@"search" sender:nil];
    }
    else  {
        
        //[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"kStringErrorInvalidLocation", nil)];
    
        //test
        [self performSegueWithIdentifier:@"search" sender:nil];
    }
}


#pragma mark - Segue

/*
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"city"]){
    }
    else if([[segue identifier] isEqualToString:@"search"]){
    }

}



@end
