//
//  main.m
//  TDYAsyncSocketServer
//
//  Created by 唐道勇 on 16/10/26.
//  Copyright © 2016年 唐道勇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Server.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        //开始
        Server *tdyServer = [Server new];
        [tdyServer start];
    }
    return 0;
}
