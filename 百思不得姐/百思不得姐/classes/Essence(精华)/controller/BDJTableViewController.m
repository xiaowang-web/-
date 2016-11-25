//
//  EssenceViewController.m
//  百思不得姐
//
//  Created by qianfeng on 16/11/21.
//  Copyright © 2016年 zhb. All rights reserved.
//

#import "BDJTableViewController.h"
#import "EssenceViewController.h"
#import "BDJEssenceModel.h"
#import "EssenceVideoCell.h"
#import <MJRefresh/MJRefresh.h>
#import "EssenceImageCell.h"
#import "EssenceTextCell.h"
#import "EssenceAudioCell.h"

@interface  BDJTableViewController()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tbView;
@property (nonatomic,strong)BDJEssenceModel *model;

//分页
@property(nonatomic,strong)NSNumber *np;

@end

@implementation BDJTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTableView];
    self.np=@(0);
    [self downloadListData];
}

-(void)createTableView{
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.tbView=[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tbView.delegate=self;
    self.tbView.dataSource=self;
    [self.view addSubview:self.tbView];
    
    //约束
    __weak typeof (self) weakSelf=self;
    [self.tbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    
    //下拉刷新
    self.tbView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadFirstPage)];
    
    //上拉加载更多
    self.tbView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadNextPage)];
}

-(void)loadFirstPage{
    self.np=@(0);
    [self downloadListData];
}

-(void)loadNextPage{
    self.np=self.model.info.np;
    [self downloadListData];
}

-(void)downloadListData{
    //开始下载
    [ProgressHUD show:@"正在下载" Interaction:NO];
    
    //http://s.budejie.com/topic/list/jingxuan/41/bs0315-iphone-4.3/0-20.json
    NSString *urlstring=[NSString stringWithFormat:@"%@/bs0315-iphone-4.3/%@-20.json",self.url,self.np];
    
    //NSString *urlstring=@"http://s.budejie.com/topic/list/jingxuan/41/bs0315-iphone-4.3/0-20.json";
    [BDJDownload downloadWithURLString:urlstring succes:^(NSData *data) {
        NSError *error=nil;
        BDJEssenceModel *model=[[BDJEssenceModel alloc]initWithData:data error:&error];
        //NSLog(@"%@",model);
        if  (error){
            //NSLog(@"%@",error);
        }else{
            if(self.np.integerValue == 0){
                //  第一页
                self.model=model;
            }else{
                // 后面页数
                NSMutableArray *tmpArray=[NSMutableArray arrayWithArray:self.model.list];
                [tmpArray addObjectsFromArray:model.list];
                model.list=(NSArray<Optional,BDJEssenceDetail> *)tmpArray;
                self.model=model;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tbView reloadData];
            [self.tbView.mj_header endRefreshing];
            [self.tbView.mj_footer endRefreshing];
            [ProgressHUD showSuccess:@"下载成功"];
        });
    } fail:^(NSError *error) {
        [ProgressHUD showError:@"下载失败"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-UItableviewdelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.model.list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BDJEssenceDetail *detail=self.model.list[indexPath.row];
    UITableViewCell *cell=nil;
    if  ([detail.type isEqualToString:@"video"]){
        cell=[EssenceVideoCell videoCellForTableView:tableView atIndexPath:indexPath withModel:detail];
    }else if ([detail.type isEqualToString:@"image"]){
        //        图片cell
        cell=[EssenceImageCell imageCellForTableView:tableView atIndexPath:indexPath withModel:detail];
    }else if ([detail.type isEqualToString:@"text"]){
        //        图片cell
        cell=[EssenceTextCell textCellForTableView:tableView atIndexPath:indexPath withModel:detail];
    }else if ([detail.type isEqualToString:@"audio"]){
        //        图片cell
        cell=[EssenceAudioCell audioCellForTableView:tableView atIndexPath:indexPath withModel:detail];
    }else{
        cell=[[UITableViewCell alloc]init];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    BDJEssenceDetail *detail=self.model.list[indexPath.row];
    return detail.cellHeight.floatValue;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 500;
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
