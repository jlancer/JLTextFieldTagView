//
//  ViewController.m
//  JLTextFieldTagViewDemo
//
//  Created by 16fan on 15/6/3.
//  Copyright (c) 2015年 16fan. All rights reserved.
//

#import "ViewController.h"
#import "JLTextFieldTagView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor grayColor];
    JLTextFieldTagView *tagView=[[JLTextFieldTagView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 44)];
    [self.view addSubview:tagView];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
