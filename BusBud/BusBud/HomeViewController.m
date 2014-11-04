//
//  ViewController.m
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
    self.navigationController.navigationBar.barTintColor = kColorBusBudBlue;
    self.navigationController.navigationBar.backgroundColor = kColorBusBudBlue;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    //version
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@ (%@) - Chris Comeau",
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    
    self.versionLabel.font = [UIFont fontWithName:@"AshemoreSoftCondMedium" size:12];
    self.versionLabel.textAlignment = NSTextAlignmentLeft;
    self.versionLabel.textColor = [UIColor whiteColor];;
    self.versionLabel.alpha = 0.4f;
    
    
    //buttons
    
    self.fromButton.titleLabel.font = [UIFont fontWithName:@"AshemoreSoftCondMedium" size:14];
    [self.fromButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.fromButton.titleEdgeInsets = UIEdgeInsetsMake(0, 25, 0, 0);

    self.toButton.titleLabel.font = [UIFont fontWithName:@"AshemoreSoftCondMedium" size:14];
    [self.toButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.toButton.titleEdgeInsets = UIEdgeInsetsMake(0, 25, 0, 0);

    self.searchButton.titleLabel.font = [UIFont fontWithName:@"AshemoreSoftCondMedium" size:14];
    [self.searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.searchButton.titleEdgeInsets = UIEdgeInsetsMake(0, 25, 0, 0);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - Actions

- (IBAction)actionFrom:(id)sender {
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"kStringNotImplemented", nil)];
}

- (IBAction)actionTo:(id)sender {
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"kStringNotImplemented", nil)];
    
}

- (IBAction)actionSearch:(id)sender {
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"kStringNotImplemented", nil)];
    
}


@end
