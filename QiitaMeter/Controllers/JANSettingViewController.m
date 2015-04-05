//
//  JANSettingViewController.m
//  QiitaMeter
//
//  Created by 神田 on 2015/03/15.
//  Copyright (c) 2015年 bob. All rights reserved.
//

#import "JANSettingViewController.h"
#import "JANDataService.h"
#import "JANQiitaUserInfoService.h"

@interface JANSettingViewController ()<UITableViewDataSource, UITableViewDelegate, JANDataServiceViewUpdateObserver>

@property (weak, nonatomic) IBOutlet UITableView *userTableView;
@property (nonatomic, strong) RLMResults *userList;
@end

@implementation JANSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userList = [JANQiitaUserInfoService qiitaUserInfosWithoutOwn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.userList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
   JANQiitaUserInfo *userInfo = [self.userList objectAtIndex:indexPath.row];
    cell.textLabel.text = userInfo.accountName;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        JANQiitaUserInfo *qiitaUserInfo = [self.userList objectAtIndex:indexPath.row];
        [JANQiitaUserInfoService deleteQiitaUserInfoWithQiitaId:qiitaUserInfo.qiitaId];
        [self.userTableView beginUpdates];
        [self.userTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.userTableView endUpdates];
        [JANDataService dataUpdateRequest:nil];
    }
}

#pragma -
- (IBAction)logOut:(id)sender {
    [JANDataService setViewUpdateToObserver:self];
    [JANDataService logoutRequest:nil];
}

- (void)updateViewWithLogout:(NSNotification *)dic
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)addUser:(id)sender {
    [self addUserAlert];
}

- (IBAction)editMode:(UIButton *)sender {
    if (self.userTableView.editing) {
        [self.userTableView setEditing:NO animated:YES];
        [sender setTitle:@"Edit Mode" forState:UIControlStateNormal];
    } else {
        [self.userTableView setEditing:YES animated:YES];
        [sender setTitle:@"Cancel" forState:UIControlStateNormal];
    }
}

#pragma -
- (void)addUserAlert{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"比較ユーザーを追加"
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Add", nil];
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];//１行で実装
    UITextField *textField = [message textFieldAtIndex:0];
    textField.placeholder = @"Qiita ID";
    [message show];
}
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    if( [inputText length] >= 1 )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        NSString *inputText = [[alertView textFieldAtIndex:0] text];
        [JANQiitaUserInfoService retrieveQiitaUserInfoWithUserId:inputText successHandler:^(JANQiitaUserInfo *userInfo) {
            // 保存済み
            // データの順番を取得し，arrayを更新して，表示を更新
            self.userList = [JANQiitaUserInfoService qiitaUserInfosWithoutOwn];
            NSUInteger row = [self.userList indexOfObjectWhere:@"qiitaId = %@", userInfo.qiitaId];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.userTableView beginUpdates];
            [self.userTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            [self.userTableView endUpdates];

        } failedHandler:^{
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"ID Error"
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:nil];
            [message show];
        }];
    }
}
@end