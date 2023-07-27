//
//  ViewController.m
//  自定义KVO
//
//  Created by 翟旭博 on 2023/7/27.
//

#import "ViewController.h"
#import "NSObject+ZXBKVO.h"
@interface ViewController ()
@property (nonatomic, strong) NSString *string;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self ZXB_addObserver:self keyPath:@"string" changeBlock:^(id  _Nonnull observer, NSString * _Nonnull key, id  _Nonnull oldValue, id  _Nonnull newValue) {
        NSLog(@"%@", self.string);
    }];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.string = [NSString stringWithFormat:@"%d", arc4random()];
}
- (void)dealloc {
    [self ZXB_removeObserver:self keyPath:@"string"];
}
@end
