//
//  tabbarView.h
//  Disney
//
//  Created by zhuang chaoxiao on 13-10-22.
//  Copyright (c) 2013年 zhuang chaoxiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol tabbarViewDelegate <NSObject>

@optional
-(void)tabClickIndex:(NSInteger) index;


@end


@interface tabbarView : UIView

@property(nonatomic,strong) UIImageView * tabbarView;
@property(nonatomic,strong) UIImageView * tabcenterView;


@property(nonatomic,strong) UIButton * btn1;
@property(nonatomic,strong) UIButton * btn2;
@property(nonatomic,strong) UIButton * btn3;
@property(nonatomic,strong) UIButton * btn4;
@property(nonatomic,strong) UIButton * btnCenter;

@property(nonatomic,assign) id<tabbarViewDelegate>  delegate;

@end
