//
//  ViewController.m
//  TDYAsyncSocketClient
//
//  Created by 唐道勇 on 16/10/26.
//  Copyright © 2016年 唐道勇. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"
#import "DYModel.h"

static NSString *serverHost = @"192.168.1.103";
static uint16_t port = 9988;
static NSString *cellID = @"MyCellID";

@interface ViewController ()<GCDAsyncSocketDelegate,UITableViewDelegate,UITableViewDataSource>
/** 客户端套接字*/
@property (nonatomic,strong)GCDAsyncSocket *clientSocket;
/** 消息数组*/
@property (nonatomic, strong) NSMutableArray *msgArray;

@property (strong, nonatomic) IBOutlet UITableView *my_tableView;
@property (strong, nonatomic) IBOutlet UITextField *my_textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.my_tableView registerNib:[UINib nibWithNibName:@"fromCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"From"];
//    [self.my_tableView registerNib:[UINib nibWithNibName:@"toCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"To"];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupSocket];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSMutableArray *)msgArray
{
    if (_msgArray == nil) {
        _msgArray = @[].mutableCopy;
    }
    return _msgArray;
}
- (void)setupSocket
{
    // 1.初始化客户端套接字
    self.clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    // 2.连接服务器
    NSError *error = nil;
    [self.clientSocket connectToHost:serverHost onPort:port withTimeout:-1 error:&error];
    if (error) {
        NSLog(@"连接服务器失败！");
    }else {
        NSLog(@"连接服务器中...");
    }
}
#pragma mark -- 代理回调

/** 连接上服务器*/
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"服务器连接成功！");
    [sock readDataWithTimeout:-1 tag:0];
}

/** 收到数据*/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",msg);  // YES&11
    //消息内容
    DYModel *model = [[DYModel alloc] init];
    model.msg = msg;
    //判断是不是自己发的
//    NSString *subString = [msg substringWithRange:NSMakeRange(0, 1)];
//    if ([subString isEqualToString:@"1"]) {
//        model.isMe = YES;
//    }else {
        model.isMe = NO;
//    }
    //加入数组
    [self.msgArray addObject:model];
    //主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.my_tableView reloadData];
        [self.my_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.msgArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    });
    [sock readDataWithTimeout:-1 tag:0];
}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    // data
}
/** 断开连接*/
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"断开连接");
}
- (IBAction)tdy_button:(UIButton *)sender {
    NSString *msg = self.my_textField.text;
    if (msg.length == 0) {
        return;
    }else {
        NSData *msgData = [msg dataUsingEncoding:NSUTF8StringEncoding];
        //发送
        [self.clientSocket writeData:msgData withTimeout:-1 tag:0];
        //自己发送的显示出来
        DYModel *model = [[DYModel alloc] init];
        model.isMe = YES;
        model.msg = msg;
        [self.msgArray addObject:model];
        [self.my_tableView reloadData];
        [self.my_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.msgArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        self.my_textField.text = @""; //使用后清零
    }
}
#pragma mark --TableView delegate/DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.msgArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取得消息对象 判断是否是我发的
    DYModel *model = self.msgArray[indexPath.row];
    
    NSString *cID = nil;
    if (model.isMe) {
        cID = @"To";
    }else {
        cID = @"From";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cID];//通过名字的到复用的cell ==== (cell的声明只在stroyBoard的，cell->tableViewCell->style 设置为Basic ,identifier设置复用声明)。
    cell.textLabel.text = model.msg;
    return cell;
}
@end
