//
//  ViewController.m
//  GridView
//
//  Created by Milan Mia on 12/2/15.
//  Copyright © 2015 apple. All rights reserved.
//

#import "ViewController.h"
#import "Flickr.h"
#import "FlickrPhoto.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableDictionary *searchResults;
@property(nonatomic, strong) NSMutableArray *searches;
@property(nonatomic, strong) Flickr *flickr;
@property (nonatomic) IBOutlet UIRefreshControl *topRefreshControl;
@property (nonatomic) int numberOfItems;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.numberOfItems = 4;
    
    self.topRefreshControl = [UIRefreshControl new];
    self.topRefreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull down to reload!"];
    [self.topRefreshControl addTarget:self action:@selector(refreshTop) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.topRefreshControl];
    
    self.searchResults = [[NSMutableDictionary alloc]init];
    self.searches = [[NSMutableArray alloc]init];
    self.flickr = [[Flickr alloc] init];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"FlickrCell"];
    [self loadImagesFromFlicker];
}
- (void)refreshTop {
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        self.numberOfItems = MAX(0, self.numberOfItems+5);
        [self.collectionView reloadData];
        [self.topRefreshControl endRefreshing];
    });
}
- (void)loadImagesFromFlicker {
    [self.flickr searchFlickrForTerm:@"Eiffel Tower" completionBlock:^(NSString *searchTerm, NSArray *results, NSError *error) {
        if(results && [results count] > 0) {
            if(![self.searches containsObject:searchTerm]) {
                NSLog(@"Found %lu photos matching %@", (unsigned long)[results count],searchTerm);
                [self.searches insertObject:searchTerm atIndex:0];
                self.searchResults[searchTerm] = results;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        } else {
            NSLog(@"Error searching Flickr: %@", error.localizedDescription);
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.numberOfItems;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.searches count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"myCell" forIndexPath:indexPath];
    NSString *searchTerm = self.searches[indexPath.section];
    FlickrPhoto *pto = self.searchResults[searchTerm][indexPath.row];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:100];
    imageView.image = pto.thumbnail;
    NSLog(@"%lld", pto.photoID);
    UILabel *label = (UILabel*)[cell viewWithTag:101];
    label.text = [NSString stringWithFormat:@"%lld", pto.photoID];
    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.collectionView.frame.size.width/2;
    CGFloat height = self.collectionView.frame.size.width/2;
    return CGSizeMake(width-15, height);
}
#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSLog(@"	Section : %ld", (long)section);
    return UIEdgeInsetsMake(0, 10, 10, 10); // top, left, bottom, right
}
- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                            UICollectionElementKindSectionHeader withReuseIdentifier:@"myCustomHeader" forIndexPath:indexPath];
    NSString *searchTerm = self.searches[indexPath.section];
    UILabel *label = (UILabel*)[headerView viewWithTag:110];
    label.text = searchTerm;
    return headerView;
}
@end
