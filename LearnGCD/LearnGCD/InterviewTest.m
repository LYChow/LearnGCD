//
//  InterviewTest.m
//  LearnGCD
//
//  Created by LY'S MacBook Air on 6/12/16.
//  Copyright © 2016 LY'S MacBook Air. All rights reserved.
//

#import "InterviewTest.h"

@interface InterviewTest ()
{
    int _n1;
    int _count;
}
@end

@implementation InterviewTest

- (void)viewDidLoad {
    [super viewDidLoad];
    /*1.考察block对局部变量和全局变量的引用规则*/
    //    _n1=2;
    //    [self blockReferenceVar:3];
    
    /*2.并行开启两个线程*/
    //    _count=0;
    //    [self dispatchConcurrentQueue];
    
    /*3.找出两个数组中不同的元素添加到第三个数组中*/
    //    [self findDifferentElements];
    
    /*4.实现字符中的某个元素进行反转如：abcdef以d为下标进行反转结果:defabc*/
    //    [self converseCharFromIndex:0 toIndex:3];
}

#pragma mark -考察block对全局变量和局部变量的引用规则
-(void)blockReferenceVar:(int)n2
{
    _n1+=n2;
    NSLog(@"1:n1=%i n2=%i",_n1,n2);  //5,3
    n2+=_n1;
    NSLog(@"2:n1=%i n2=%i",_n1,n2);  //5,8
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        _n1+=n2;
        NSLog(@"5:n1=%i n2=%i",_n1,n2); //26,8
        
    });
    
    
    n2+=_n1;
    NSLog(@"3:n1=%i n2=%i",_n1,n2); //5,13
    
    _n1+=n2;
    NSLog(@"4:n1=%i n2=%i",_n1,n2); //18,13
    
    
}

#pragma mark -开启两个异步线程放在并行队列,各执行线程1执行函数func1 n1次,线程2执行函数func2 n2次之后,再回到主线程执行func3
-(void)dispatchConcurrentQueue
{
    int n1 = random()%10;
    int n2 =random()%10;
    
    dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group =  dispatch_group_create();
    
    __weak typeof(self) weakSelf =self;
    
    dispatch_group_async(group, queue, ^{
        for (int i=0;i< n1; i++) {
            [weakSelf func1];
            NSLog(@"---1:currrentThread:%@",[NSThread currentThread]);
        }
    });
    
    dispatch_group_async(group, queue, ^{
        for (int i=0;i< n2; i++) {
            [weakSelf func2];
            NSLog(@"---2:currrentThread:%@",[NSThread currentThread]);
        }
    });
    
    dispatch_group_notify(group, queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf fun3];
            NSLog(@"---3:currrentThread:%@",[NSThread currentThread]);
        });
        
    });
}

-(void)func1
{
    _count--;
    NSLog(@"func1: _count=%i",_count);
}

-(void)func2
{
    _count++;
    NSLog(@"func2: _count=%i",_count);
}

-(void)fun3
{
    NSLog(@"func3: _count=%i",_count);
}

#pragma mark -找出数组a[]与数组b[]中不同的元素,添加到数组c[]中,结果以c[0] c[1] cLen=2的形式展示
-(void)findDifferentElements
{
    int a[]={1,2,3,4,5,-2};
    int aLen =6;
    
    int b[]={3,4,5,6,7,8};
    int bLen =6;
    
    
    int cLen=0;
    int c[100];
    for (int i=0; i<aLen; i++)
    {
        BOOL isWantElement =YES;
        
        for (int j=0; j<bLen; j++)
        {
            if (a[i]==b[j]) {
                isWantElement =NO;
                continue;
            }
        }
        if (isWantElement) {
            c[cLen] = a[i];
            cLen++;
        }
    }
    
    
    for (int i=0; i<bLen; i++)
    {
        BOOL isWantElement =YES;
        
        for (int j=0; j<aLen; j++)
        {
            if (a[j]==b[i]) {
                isWantElement =NO;
                continue;
            }
        }
        if (isWantElement) {
            c[cLen] = b[i];
            cLen++;
        }
    }
    
    
    for (int i=0; i<cLen; i++) {
        printf("\n c[%i] = %i",i,c[i]);
    }
    printf("\n cLen=%i",cLen);
}
int a[7] ={1,2,3,4,5,6,7};

//#pragma mark -根据某个字符对整个串进行反转
//-(void)converseCharFromIndex:(int)from toIndex:(int)to
//{
////abcdef-->cbadef-->abafed--->defabc 先把前半段进行反转-->再把后半段进行反转-->整个字符串进行一次反转
//    //c之前的字符反转
//
//    for (int i=from; i<to; i++) {
//        if (i<=(from+to)/2) {
//            int temp = a[i];
//            a[i]=a[to-1-i];
//            a[to-1-i]=temp;
//        }
//    }
//    for (int i =0; i<7; i++) {
//         printf("%i",a[i]);
//    }
//    printf("\n");
//   
//}


@end
