//
//  Server.m
//  TDYAsyncSocketServer
//
//  Created by 唐道勇 on 16/10/26.
//  Copyright © 2016年 唐道勇. All rights reserved.
//

#import "Server.h"
#import "GCDAsyncSocket.h"

static uint16_t  port = 9988;

@interface Server () <GCDAsyncSocketDelegate>

/** 服务器套接字*/
@property (nonatomic, strong) GCDAsyncSocket *serverSocket;
/** 存储连接上的客户端套接字*/
@property (nonatomic, strong) NSMutableArray *clientSocketArray;

@end

@implementation Server
/**懒加载*/
- (NSMutableArray *)clientSocketArray
{
    if (_clientSocketArray == nil) {
        _clientSocketArray = @[].mutableCopy;
    }
    return _clientSocketArray;
}

- (void)start
{
    // 1.初始化服务端套接字
    // 参数1： 代理
    // 参数2： 队列
    self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    // 2.绑定ip和端口 / 监听 / 接收客户端连接
    NSError *error = nil;
    
    [self.serverSocket acceptOnPort:port error:&error];
    
    if (error) {
        NSLog(@"服务器启动失败！");
    }else {
        NSLog(@"服务器启动成功！");
    }
    [[NSRunLoop currentRunLoop] run];//创建一个runloop跑
}

#pragma mark - Socket代理回调

/** 收到一个新的socket连接*/
- (void)socket:(GCDAsyncSocket *)serverSock didAcceptNewSocket:(GCDAsyncSocket *)clientSocket {
    //打印信息
    NSLog(@"client.ip = %@,  port = %d",clientSocket.connectedHost,clientSocket.connectedPort);
    //设置代理
    clientSocket.delegate = self;
    // 加入数组，让客户端套接字不会释放
    [self.clientSocketArray addObject:clientSocket];
    // 发送欢迎消息
    NSString *welCome = @"欢迎来到唐道勇创建的服务器！";
    NSData *welcomeData = [welCome dataUsingEncoding:NSUTF8StringEncoding];//编码
    [clientSocket writeData:welcomeData withTimeout:-1 tag:0];

    /** 参数一：超时时间， 参数二：本次socket连接标识*/
    [clientSocket readDataWithTimeout:-1 tag:0];
}
// 100+100k, 50k, 50k
/** 收到客户端发来的消息*/
- (void)socket:(GCDAsyncSocket *)clientSocket didReadData:(NSData *)data withTag:(long)tag
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];//收到客户端发来的NSString信息，转码
    NSLog(@"msg = %@",msg);
    // 写入消息，
    for (GCDAsyncSocket *sock in self.clientSocketArray) {
        NSString *retMsg = nil;
        
        if (sock == clientSocket) {
            retMsg = [@"1" stringByAppendingString:msg];
            // data 包含 isMe = yes  // yes&11
        }else {
            //data 包含 isME =NO;
            retMsg = [@"0" stringByAppendingString:msg];
        }
        NSData *retData = [retMsg dataUsingEncoding:NSUTF8StringEncoding];
        [sock writeData:retData withTimeout:-1 tag:0];
    }
    // 收到消息之后，重新开始读取消息
    [clientSocket readDataWithTimeout:-1 tag:0];
}
/** 断开连接*/
- (void)socketDidDisconnect:(GCDAsyncSocket *)clientSock withError:(NSError *)err
{
    //从数组中移除 连接的客户端套接字
    [self.clientSocketArray removeObject:clientSock];
    NSLog(@"套接字断开");
}
- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock
{
    NSLog(@"%s",__func__);
}
@end
