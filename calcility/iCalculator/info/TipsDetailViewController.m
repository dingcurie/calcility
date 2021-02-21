//
//  TipsDetailViewController.m
//  iCalculator
//
//  Created by curie on 13-7-29.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "TipsDetailViewController.h"


@interface TipsDetailViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (void)refresh;

@end


@implementation TipsDetailViewController

- (void)setPageURL:(NSURL *)pageURL
{
    _pageURL = pageURL;
    
    [self refresh];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//! WORKAROUND: UIWebView doesn't get its scroll view's insets auto-adjusted on iPad since iOS 8.
- (void)viewDidLayoutSubviews
{
    if (!g_isPhone && 8 <= g_osVersionMajor) {
        UIScrollView *scrollView = self.webView.scrollView;
        UIEdgeInsets insets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0, self.bottomLayoutGuide.length, 0.0);
        scrollView.contentInset = insets;
        scrollView.scrollIndicatorInsets = insets;
    }
}

- (void)refresh
{
    if (self.webView && self.pageURL) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.pageURL]];
    }
}

@end
