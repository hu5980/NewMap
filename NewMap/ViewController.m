//
//  ViewController.m
//  NewMap
//
//  Created by 忘、 on 16/6/28.
//  Copyright © 2016年 xikang. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>


@interface ViewController () <CLLocationManagerDelegate,MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation ViewController {
    CLLocationManager * locationmanager;
    
    NSMutableArray  *pointsArray;
    MKPolyline* routeLine;
    MKPolylineView* routeLineView;
    
    UILabel *label;
    
    UILabel *label2;
    
    CLGeocoder *geocoder;

    
    NSString *plistPath;
    
    NSMutableArray *locationArray;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationArray = [NSMutableArray array];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    plistPath= [documentsDirectory stringByAppendingPathComponent:@"plist.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
  
    if ([fileManager fileExistsAtPath: plistPath]) {
        locationArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
        NSLog(@"%@",locationArray);
    }
    
    
    _mapView.mapType = MKMapTypeStandard;
    _mapView.showsUserLocation = YES;
    
    _mapView.zoomEnabled = YES;//支持缩放
    
    _mapView.delegate = self;
    
    [self getCurPosition];
    pointsArray = [NSMutableArray array];
   
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, [[UIScreen mainScreen] bounds].size.width, 50)];
    label.backgroundColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    label.numberOfLines = 0;
    [_mapView addSubview:label];
    
    
    label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, [[UIScreen mainScreen] bounds].size.width, 50)];
    label2.backgroundColor = [UIColor whiteColor];
    label2.font = [UIFont systemFontOfSize:14];
    label2.numberOfLines = 0;
    [_mapView addSubview:label2];
    
    geocoder = [[CLGeocoder alloc] init];
      // Do any additional setup after loading the view, typically from a nib.
}


- (void) getCurPosition
{
    //开始探测自己的位置
    if (locationmanager==nil)
    {
        locationmanager =[[CLLocationManager alloc] init];
    }
    
    
    if ([CLLocationManager locationServicesEnabled])
    {
        locationmanager.delegate=self;
        locationmanager.desiredAccuracy=kCLLocationAccuracyBest;
        locationmanager.distanceFilter=0.5f;
        [locationmanager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@",error.description);
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location=[locations firstObject];//取出第一个位置
 
  //  NSLog(@"经度：%f,纬度：%f,海拔：%f,航向：%f,行走速度：%f",coordinate.longitude,coordinate.latitude,location.altitude,location.course,location.speed);
   
    label2.text = [NSString stringWithFormat:@"海拔：%.1f,航向：%f,行走速度：%.1f",location.altitude,location.course,location.speed];
}


- (void)setMapRoutes
{
    MKMapPoint *pointArray = malloc(sizeof(CLLocationCoordinate2D) *pointsArray.count);
    for(int idx = 0; idx < pointsArray.count; idx++)
    {
        CLLocation *location = [pointsArray objectAtIndex:idx];
        CLLocationDegrees latitude  = location.coordinate.latitude;
        CLLocationDegrees longitude = location.coordinate.longitude;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        MKMapPoint point = MKMapPointForCoordinate(coordinate);
        pointArray[idx] = point;
    }
    
    if (routeLine) {
        [self.mapView removeOverlay:routeLine];
    }
    
    routeLine = [MKPolyline polylineWithPoints:pointArray count:pointsArray.count];
    if (nil != routeLine) {
        [self.mapView addOverlay:routeLine];
    }
    
    free(pointArray);
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
     if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer=[[MKPolylineRenderer alloc]initWithOverlay:overlay];
        renderer.strokeColor=[[UIColor blueColor]colorWithAlphaComponent:0.5];
        renderer.lineWidth=5.0;
        return renderer;
     }
    return nil;
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(userLocation.coordinate.latitude == 0.0f || userLocation.coordinate.longitude == 0.0f)    return;
    [pointsArray addObject:userLocation];
    
     NSMutableDictionary *locationDic = [[NSMutableDictionary alloc]init];
    [locationDic setValue:[NSString stringWithFormat:@"%f",userLocation.coordinate.longitude] forKey:@"longitude"];
    [locationDic setValue:[NSString stringWithFormat:@"%f",userLocation.coordinate.latitude] forKey:@"latitude"];
    
    [locationArray addObject:locationDic];
    
    BOOL isSuccess =  [locationArray writeToFile:plistPath atomically:YES];
    
    if (isSuccess) {
        NSLog(@"写入成功");
    }else{
        NSLog(@"写入失败");
    }
     
    CLLocationCoordinate2D pos = userLocation.coordinate;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(pos,500, 500);//以pos为中心，显示2000米
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];//适配map view的尺寸
    [_mapView setRegion:adjustedRegion animated:YES];
    
    [self setMapRoutes];
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        NSLog(@"%@", placemarks[0]);
    }];
    label.text = [NSString stringWithFormat:@"    纬度= %f  经度= %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
