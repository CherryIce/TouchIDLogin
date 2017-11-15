//
//  LonginViewController.m
//  TouchIDLogin
//
//  Created by Macx on 2017/11/15.
//  Copyright © 2017年 Macx. All rights reserved.
//

#import "LonginViewController.h"

#import "KeychainItemWrapper.h"

#import <LocalAuthentication/LocalAuthentication.h>

@interface LonginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneTf;

@property (weak, nonatomic) IBOutlet UITextField *passwordTf;

@end

@implementation LonginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //判断是否是第一次打开app
    NSString * value = [[NSUserDefaults standardUserDefaults] objectForKey:@"first"];
    if ([LonginViewController isempty:value]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"first"];
    }
    if (![value isEqualToString:@"1"]) {
        [self touchIDLogin];
    }
}

/**
 指纹验证
 */
- (void) touchIDLogin
{
    //说明用户不是已经登录过，准备指纹验证即可
    LAContext * context = [[LAContext alloc] init];
    NSError * error = nil;
    NSString * reason = @"我们需要验证您的指纹来确认您的身份";
    
    context.localizedFallbackTitle = @"";
    
    //  NSLog(@"是否进入了指纹=========");
    
    // 判断设置是否支持指纹识别(iPhone5s+、iOS8+支持)
    if([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]){
        
        // 指纹识别只判断当前用户是否是机主
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:^(BOOL success, NSError * _Nullable error) {
            //                if(success){
            //                    NSLog(@"指纹认证成功");
            //                }else{
            //指纹认证失败
            //                    NSLog(@"错误码：%zd",error.code);
            //                    NSLog(@"出错信息：%@",error);
            
            //使用密码登录
            
            
            
            // 错误码 error.code
            // -1: 连续三次指纹识别错误
            // -2: 在TouchID对话框中点击了取消按钮
            // -3: 在TouchID对话框中点击了输入密码按钮
            // -4: TouchID对话框被系统取消，例如按下Home或者电源键
            // -8: 连续五次指纹识别错误，TouchID功能被锁定，下一次需要输入系统密码
            //                }
            
            [self refreshUI:success];
        }];
    }
}

/**
 账号密码登录
 */
- (IBAction)loginAccount:(UIButton *)sender
{
    [self.view endEditing:YES];
    [self requestLogin];
}

/**
 存储密码的登录操作
 */
- (void) requestLogin
{
    KeychainItemWrapper *keyWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Keychain" accessGroup:nil];
    
    NSString *name = [keyWrapper objectForKey:(id)kSecAttrAccount];
    
    NSString *password = [keyWrapper objectForKey:(id)kSecValueData];
    
    if ([LonginViewController isempty:_phoneTf.text] || [LonginViewController isempty:_passwordTf.text]) {
        [self showMessage:@"登录信息不能为空"];
        return;
    }
    
    if ([LonginViewController isempty:name] || [LonginViewController isempty:password]) {
        /**
         存账号
         */
        KeychainItemWrapper * saver = [[KeychainItemWrapper alloc] initWithIdentifier:@"Keychain" accessGroup:nil];
        
        [saver setObject:@"myChainValues" forKey:(id)kSecAttrService];
        
        [saver setObject:_phoneTf.text forKey:(id)kSecAttrAccount];// 上面两行用来标识一个Item
        
        [saver setObject:_passwordTf.text forKey:(id)kSecValueData];
        
        //登录过就不再是第一次了
        [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"first"];
        [self loginSucess];
    }
    
    if (![LonginViewController isempty:name] && ![LonginViewController isempty:password] && [_phoneTf.text isEqualToString:name] && [password isEqualToString:_passwordTf.text]) {
        [self loginSucess];
    }
}

/**
 指纹验证是否成功
 sucess 刷新界面
 failed 失败三次只能账号密码登录
 **/
-(void)refreshUI:(BOOL) isSuccess{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(isSuccess)
        {
            //成功
            //method:存储了用户的个人信息,uid,但可以不包含密码，之后所有操作界面都是由uid获取信息
            
            [self loginSucess];
            [self showMessage:@"验证成功"];
            
        }else{
            //失败
            [self showMessage:@"验证失败"];
        }
    });
}

/**
 提示信息
 */
- (void) showMessage:(NSString *)msg
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 判断字符串是否为空
 */
+ (BOOL) isempty:(NSString *) value
{
    if ([value isKindOfClass:[NSNull class]] || value == nil) {
        return true;
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [value isEqualToString:@""] || [[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0;
    }
    return false;
}

/**
 成功后的操作
 */
- (void) loginSucess
{
    //登陆成功了那就将token置成yes
    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"token"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
