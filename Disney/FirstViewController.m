//
//  FirstViewController.m
//  Disney
//
//  Created by zhuang chaoxiao on 13-10-24.
//  Copyright (c) 2013年 zhuang chaoxiao. All rights reserved.
//

#import "FirstViewController.h"
#import "TourCellView.h"
#import "JSONKit.h"
#import "EGORefreshTableHeaderView.h"
#import "SDWebImageManager.h"
#import "GADBannerView.h"
#import "dataStruct.h"
#import "YouMiWall.h"
#import "MyAdmobView.h"

#define BIG_IMAGE_TAG  1001


@interface FirstViewController ()<EGORefreshTableHeaderDelegate>
{
    UIImageView * _bigImgView;
    IntroInfo * _intro;
    
    CGFloat _yPos;
    BOOL  _isLoading;
    
}

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    else
    {
        //self.view.frame =CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height-CUSTOM_TAB_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT-5);
    }
#endif
    
    CGRect rect = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height-CUSTOM_TAB_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT-5);
    
    _scrView = [[UIScrollView alloc]initWithFrame:rect];
    
    [self.view addSubview:_scrView];
    
    
    _intro = [[IntroInfo alloc]init];
    
    
    [self parseData];

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self showYOUMIAdv];
}

-(void)showYOUMIAdv
{
    NSDateComponents * data = [[NSDateComponents alloc]init];
    NSCalendar * cal = [NSCalendar currentCalendar];
    
    [data setCalendar:cal];
    [data setYear:SHOW_ADV_YEAR];
    [data setMonth:SHOW_ADV_MONTH];
    [data setDay:SHOW_ADV_DAY];
    
    NSDate * farDate = [cal dateFromComponents:data];

    NSDate *now = [NSDate date];
    
    NSTimeInterval farSec = [farDate timeIntervalSince1970];
    NSTimeInterval nowSec = [now timeIntervalSince1970];
    
    
    if( nowSec - farSec >= 0 )
    {
        if((int)nowSec % 2 == 0 )
        {
            [YouMiWall showOffers:NO didShowBlock:^{
                NSLog(@"有米积分墙已显示");
            } didDismissBlock:^{
                NSLog(@"有米积分墙已退出");
            }];
        }
        else
        {
            [[MyAdmobView alloc]initWithViewController:self];
        }
    }
}



-(void)showBigImg:(BOOL)bShow withUrlStr:(NSString*)strUrl
{
    if( _bigImgView == nil )
    {
        _bigImgView = [[UIImageView alloc]initWithFrame:CGRectMake(320/2.0, 320*(200/300.0)/2.0, 0, 0)];
        _bigImgView.userInteractionEnabled = YES;
        _bigImgView.tag = BIG_IMAGE_TAG;
        
        UITapGestureRecognizer * g = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickImage:)]autorelease];
        [_bigImgView addGestureRecognizer:g];
        
        
        [_scrView addSubview:_bigImgView];
    }
    
    if( bShow )
    {
        _bigImgView.image = [[SDWebImageManager sharedManager] imageWithURL:[NSURL URLWithString:strUrl]];
        
        _bigImgView.hidden = NO;
        
        [UIView beginAnimations:@"showImg" context:nil];
        [UIView setAnimationDuration:0.8f];
        
        _bigImgView.frame = CGRectMake(0, 0, 320, 320*(200/300.0));
        
        [UIView commitAnimations];
    }
    else
    {
        [UIView beginAnimations:@"showImg" context:nil];
        [UIView setAnimationDuration:0.8f];
        
        _bigImgView.frame = CGRectMake(320/2.0, 320*(200/300.0)/2.0, 0, 0);
        
        [UIView commitAnimations];
        
        _bigImgView.hidden = NO;
    }
}


-(void)layoutSepImgView:(UIView*)parView wihtRect:(CGRect)rect
{
    UIImageView * imgSepView;
    
    imgSepView = [[[UIImageView alloc]initWithFrame:rect]autorelease];
    imgSepView.image = [UIImage imageNamed:@"sepLine"];
    [parView addSubview:imgSepView];
}



- (float) heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width
{
    CGSize sizeToFit = [value sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return sizeToFit.height;
}


-(void)laytouADVView:(CGRect)rect
{
     GADBannerView *_bannerView;
     _bannerView = [[[GADBannerView alloc]initWithFrame:rect]autorelease];//设置位置
    
    _bannerView.adUnitID = ADMOB_ID;//调用你的id
    
    _bannerView.rootViewController = self;
    
    [_scrView addSubview:_bannerView];//添加bannerview到你的试图
    
    [_bannerView loadRequest:[GADRequest request]];
}


-(CGSize)getStringHeightWithFont:(UIFont*)font withSize:(CGSize)orgSize withStr:(NSString*)str
{
    CGSize size;
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    
    size = [str boundingRectWithSize:orgSize options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    
    return size;
}

-(void)layoutTextView
{
    CGFloat yBegin = _yPos;
    CGFloat strHeight;
    CGRect rect;
    CGSize size;
    
    //广告
    
    yBegin += 5;
    rect = CGRectMake(5, yBegin, 310, 100);
    [self laytouADVView:rect];
    
    //
    yBegin += 100+5;
    
    rect = CGRectMake(10, yBegin , 300, 2);
    [self layoutSepImgView:_scrView wihtRect:rect];
    
    
    for( subIntroInfo * subInfo in _intro.descArray )
    {
        rect = CGRectMake(10, yBegin, 300, 30);
        UILabel * labTitle = [[[UILabel alloc]initWithFrame:rect]autorelease];
        labTitle.text = subInfo.title;
        [_scrView addSubview:labTitle];
        
        labTitle.font = [UIFont boldSystemFontOfSize:20];
        yBegin += 30;
        
        //
        for( NSString * str in subInfo.valArray )
        {
            rect = CGRectMake(10, yBegin, 300, 20);
            UILabel * labVal = [[[UILabel alloc]initWithFrame:rect]autorelease];
            labVal.text = str;
            [_scrView addSubview:labVal];
            
            UIFont * font = [UIFont systemFontOfSize:16];
            labVal.font = font;
            size = [self getStringHeightWithFont:labVal.font withSize:CGSizeMake(300, CGFLOAT_MAX) withStr:labVal.text];
            labVal.frame = CGRectMake(10, yBegin, 300, size.height);
            labVal.numberOfLines = 0;
            labVal.lineBreakMode = NSLineBreakByWordWrapping;
            
            labVal.frame = CGRectMake(10, yBegin, 300, size.height);
            
            yBegin += size.height;
        }
    }
    
    
    
    yBegin += 20;
    _scrView.contentSize =CGSizeMake(320, yBegin);
    
}


- (void)setTextViewFrame:(UITextView *)textView
{
    /*  before  ios7
      */
    
    // ios7
    
    if( DEVICE_VER_OVER_7 == YES )
    {
        CGRect txtFrame = textView.frame;
        CGFloat textViewContentHeight = txtFrame.size.height =[[NSString stringWithFormat:@"%@\n  ",textView.text]
                                                               boundingRectWithSize:CGSizeMake(txtFrame.size.width, CGFLOAT_MAX)
                                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                               attributes:[NSDictionary dictionaryWithObjectsAndKeys:textView.font,NSFontAttributeName, nil] context:nil].size.height;
        
        txtFrame.size.height = textViewContentHeight;
        
        textView.frame = txtFrame;


    }
    else
    {
        CGFloat fixedWidth = textView.frame.size.width;
        CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = textView.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        textView.frame = newFrame;

    }
}


-(void)layoutImageView
{
    #define IMG_LEFT_TIP 5
    #define IMG_TOP_TIP 5
    #define IMG_RIGHT_TIP 5
    #define IMG_WIDHT 100
    #define IMG_HEIGHT 66
    #define ONE_LINE_IMG_COUNT 3
    
    NSInteger index = 0;
    
    for( index = 0; index < [_intro.imgUrlArray count]; ++ index )
    {
        CGRect rect;
        rect = CGRectMake(IMG_LEFT_TIP + index%ONE_LINE_IMG_COUNT*(IMG_WIDHT+IMG_RIGHT_TIP), IMG_TOP_TIP + index/ONE_LINE_IMG_COUNT*(IMG_HEIGHT+IMG_TOP_TIP), IMG_WIDHT, IMG_HEIGHT);
        
        UIImageView * imageView = [[[UIImageView alloc]initWithFrame:rect]autorelease];
        
        NSString * filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[_intro.imgUrlArray objectAtIndex:index]];
        
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        imageView.image = image;
        
        ////
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer * g = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickImage:)]autorelease];
        [imageView addGestureRecognizer:g];
        imageView.tag = index;
        /////
        
        [_scrView addSubview:imageView];
        
        _yPos = rect.origin.y + rect.size.height;

    }
}


-(void)clickImage:(UITapGestureRecognizer*)g
{
    if( g.view.tag == BIG_IMAGE_TAG )
    {
        [self showBigImg:NO withUrlStr:nil];
    }
    else
    {
        [self showBigImg:YES withUrlStr:[ _intro.imgUrlArray objectAtIndex:g.view.tag]];
    }
}

//解析数据
-(void)parseData
{
    
    NSString * filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Introinfo.txt"];

    NSString * str = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary * dict = [data objectFromJSONData];
    
    [_intro fromDict:dict];
    
    
    [self layoutImageView];
    
    [self layoutTextView];

}


-(void)dealloc
{
    [_conn release];
    [_data release];
    [_scrView release];
    
    [_intro release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


























