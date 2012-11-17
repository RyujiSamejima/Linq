//
//  ViewController.m
//  LinqTestApp
//
//  Created by 鮫島 隆治 on 2012/11/17.
//  Copyright (c) 2012年 鮫島 隆治. All rights reserved.
//

#import "ViewController.h"
#import "NSEnumerator+Query.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self test];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)test {
//    for (NSArray *xs in [[NSEnumerator range:0 to:10]buffer:4])
//    {
//        [[xs objectEnumerator]forEach:^(id item) {
//            NSLog(@"%@",item);
//        }];
//        NSLog(@"----");
//    }
}
@end
