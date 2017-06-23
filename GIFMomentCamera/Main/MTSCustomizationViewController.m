//
//  MTSCustomizationViewController.m
//  GIFMomentCamera
//
//  Created by Monster on 22/06/2017.
//  Copyright © 2017 MonsterTech Studio. All rights reserved.
//

#import "MTSCustomizationViewController.h"
#import "MTSFilterCollectionViewCell.h"
#import "MTSFilterDataModel.h"
static NSString *mFilterCellID = @"MTSFilterCollectionViewCell";

@interface MTSCustomizationViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *save;
@property (weak, nonatomic) IBOutlet SCVideoPlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIView *customizationOptionsView;
@property (strong, nonatomic) SCPlayer *player;
@property (weak, nonatomic) IBOutlet UIButton *customizationOptions;
@property (weak, nonatomic) IBOutlet UICollectionView *FiltersCollectionView;
@property (strong, nonatomic) NSArray *filtersData;
@property (strong, nonatomic) NSMutableArray *filters;
@end

@implementation MTSCustomizationViewController

#pragma mark - LIFE CYCLE

- (void)viewDidLoad {
    [super viewDidLoad];
    _player = [SCPlayer player];
    _playerView.player = _player;
    _playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _player.loopEnabled = YES;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _FiltersCollectionView.collectionViewLayout = layout;
    _FiltersCollectionView.delegate = self;
    _FiltersCollectionView.dataSource = self;
    [_FiltersCollectionView registerNib:[UINib nibWithNibName:mFilterCellID bundle:nil] forCellWithReuseIdentifier:mFilterCellID];
    [self loadFiltersData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_player setItemByAsset:_recordSession.assetRepresentingSegments];
    [_player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_recordSession removeAllSegments];
    [_player pause];
}

#pragma mark - UICollectionViewDataSource
//cell config
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MTSFilterCollectionViewCell *cell = [_FiltersCollectionView dequeueReusableCellWithReuseIdentifier:mFilterCellID forIndexPath:indexPath];
    cell.filterData = _filtersData[indexPath.row];
    return  cell;
}
// items number for section
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _filtersData.count;
}
// sections number
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
#pragma mark - UICollectionViewDelegateFlowLayout
// cell margins
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
// cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellWidth = kScreenWidth * 0.24;
    NSInteger cellHeight = cellWidth * 1.2;
    return CGSizeMake(cellWidth,cellHeight );
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - ACTIONS

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(UIBarButtonItem *)sender {
    
}

#pragma mark - HELPERS

- (void)loadFiltersData {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"filtersData" ofType:@"json"];
    NSString *filterJSONString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    if (filterJSONString) {
        NSDictionary *filterJSONDic = [self dictionaryWithJsonString:filterJSONString];
        _filtersData = [MTLJSONAdapter modelsOfClass:[MTSFilterDataModel class] fromJSONArray:filterJSONDic[@"Filters"] error:nil];
        NSMutableArray *temp = [NSMutableArray array];
        if ([_filtersData count]) {
            for (int i = 0; i < _filtersData.count; i ++) {
                MTSFilterDataModel *filterData = _filtersData[i];
              SCFilter *filter = [SCFilter filterWithContentsOfURL:[[NSBundle mainBundle] URLForResource:filterData.FilterPath withExtension:@"cisf"]];
                [temp addObject:filter];

            }
            _filters = [NSMutableArray arrayWithArray:temp];
        }
    }
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        
        return nil;
        
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        NSLog(@"json解析失败：%@",err);
        
        return nil;
        
    }
    
    return dic;
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
