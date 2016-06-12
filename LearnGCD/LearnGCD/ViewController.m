//
//  ViewController.m
//  LearnGCD
//
//  Created by LY'S MacBook Air on 6/11/16.
//  Copyright © 2016 LY'S MacBook Air. All rights reserved.
//

#import "ViewController.h"

typedef void(^ThreadSafeDictionary)(NSDictionary *dict,NSString *key,id object);
@interface ViewController ()
{
    dispatch_queue_t concurrentqueue;
}
@end

@implementation ViewController

-(id)init
{
    if (self) {
        concurrentqueue = dispatch_queue_create("concurrent_queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)objectForKey:(id)aKey block:(ThreadSafeDictionary)block
{
    id key = [aKey copy];
    __weak typeof(self) weakSelf =self;
    dispatch_async(concurrentqueue, ^{
        NSMutableDictionary *dict =weakSelf;
        if (!weakSelf)
            return ;
        id object = [dict objectForKey:key];
        block(dict,key,object);
    });
    
}

- (void)setObject:(id)object forKey:(NSString *)key block:(ThreadSafeDictionary)block
{
 //设置的时候停止执行其他的线程操作
    if(!object || !key) return;
    id akey = [key copy];
    __weak typeof(self) weakSelf =self;
    
    dispatch_barrier_async(concurrentqueue, ^{
        NSMutableDictionary *dict =weakSelf;
        if (!dict) return ;
        [dict setObject:object forKey:akey];
        
        if (block) {
            block(dict,akey,object);
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    //在serial_queue中开启异步线程
//    [self testSerialQueueWithAsync];
    
    //在concurrent_queue中开启异步线程
//    [self testConcurrentQueueAysnc];
    
    //dispatch_barrier在并行队列拦截任务
//    [self testDispatchBarrierOnConcurrentQueue];
    
    //测试NSMutableDictionary是否线程安全
    [self testMutableDictionaryThreadSafe];
}

- (void)testSerialQueueWithAsync
{
    //串行队列,FIFO,dispatch_async开启子线程不阻塞主线程
  dispatch_queue_t serial_queue =  dispatch_queue_create("serial_queue", DISPATCH_QUEUE_SERIAL);
    
    
    for (int index=0; index<10; index++) {
        dispatch_async(serial_queue, ^{
            NSLog(@"currentThread--%@",[NSThread currentThread]);
        });
    }
    
    NSLog(@"runing on main Thread");
}

-(void)testConcurrentQueueAysnc
{
    //并发队列,每次执行任务都开辟一条新的线程,线程的开始、结束不一样导致了乱序
    dispatch_queue_t concurrent_queue =dispatch_queue_create("concurrent_queue", DISPATCH_QUEUE_CONCURRENT);
    
    for (int index=0; index<10; index++) {
        dispatch_async(concurrent_queue, ^{
            NSLog(@"currentThread--%@",[NSThread currentThread]);
        });
    }
        NSLog(@"runing on main Thread");
}

-(void)testDispatchBarrierOnConcurrentQueue
{
//在并行队列中,dispatch_barrier之后的任务总会等待dispatch_barrier之前的任务执行完才执行
    
//dispatch_barrier_async,会开启一条新的线程不会阻塞当前线程
    
//dispatch_barrier是同一个队列中一些并发任务必须在另一些并发任务之后执行,迫使执行任务必须等待,而global_queue系统分配给你的可能是不同的队列,你在其中一个队列添加barrier并没有意义
    
   //    barrier实现的基础条件是要在同一个队列中
    dispatch_queue_t concurrent_queue =dispatch_queue_create("concurrent_queue", DISPATCH_QUEUE_CONCURRENT);
    
//    dispatch_queue_t concurrent_queue1 =dispatch_queue_create("concurrent_queue1", DISPATCH_QUEUE_CONCURRENT);
    
//     dispatch_queue_t global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(concurrent_queue, ^{
        for (int i =0; i<10; i++) {
            NSLog(@"index = %i currentThread=%@",i,[NSThread currentThread]);
        }
    });
    
    dispatch_barrier_async(concurrent_queue, ^{
        for (int i=0; i<10000; i++) {
            if (i==10000-1) {
                NSLog(@"barrier finished currentThread=%@",[NSThread currentThread]);
            }
        }
        
    });
    
    NSLog(@"running on main Thread");
    
    dispatch_async(concurrent_queue, ^{
        for (int i =10; i<20; i++) {
            NSLog(@"after barrier Task: index = %i currentThread=%@",i,[NSThread currentThread]);
        }
    });
    
}

- (void)testMutableDictionaryThreadSafe
{
    NSMutableDictionary *dict =[NSMutableDictionary dictionary];
    
     dispatch_queue_t concurrent_queue =dispatch_queue_create("concurrent_queue", DISPATCH_QUEUE_CONCURRENT);
    
    
    dispatch_semaphore_t semaphore =dispatch_semaphore_create(0);
    dispatch_async(concurrent_queue, ^{
        for (int i = 0; i<100; i++) {
            dict[@(i)]=@(i);
//            NSLog(@"currentThread--%@",[NSThread currentThread]);
        }
        dispatch_semaphore_signal(semaphore);
    });
    
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
//    NSLog(@"dict=%@",dict);
//    NSLog(@"%@",[NSThread currentThread]);

}




-(void)dispatchMethods
{
 //异步下载操作,下载完成成在主线程显示下载内容
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //下载数据
        NSError *error;
        NSURL *url= [NSURL URLWithString:@"www.baidu.com"];
        NSString *data = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if (data) {
        //回到主线程,把内容显示出来
            dispatch_async(dispatch_get_main_queue(), ^{
               //显示出来
            });
        }
        else
        {
            NSLog(@"error=%@",error);
        }
        
    });
    
    //后台执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
    });
    //一次执行
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
    });
    //主线程执行
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
    //延迟执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
    });
}

//两个异步线程完成,执行其他操作
-(void)taskAddDependency
{

    dispatch_group_t group =dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        //任务1
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
       //任务2
    });
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
       //主线程执行任务
    });
}

#pragma -mark后台运行任务

-(void)runBackgroundTask
{
   self.backgroundTaskIdentifier =[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
   //执行耗时操作
       [self endBackgroundTask];
}];
}

-(void)endBackgroundTask
{
    [[UIApplication sharedApplication]endBackgroundTask:self.backgroundTaskIdentifier];
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
}














@end
