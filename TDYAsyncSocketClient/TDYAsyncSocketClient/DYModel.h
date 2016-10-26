//
//  DYModel.h
//  TDYAsyncSocketClient
//
//  Created by 唐道勇 on 16/10/26.
//  Copyright © 2016年 唐道勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DYModel : NSObject

/** 是否是我发的*/
@property (nonatomic, assign) BOOL isMe;
/** 消息内容*/
@property (nonatomic, copy) NSString *msg;

@end
