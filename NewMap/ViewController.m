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
    
    CLGeocoder *geocoder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
//    label.hidden = YES;
    [_mapView addSubview:label];
    
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
        locationmanager.distanceFilter=1.0f;
        [locationmanager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@",error.description);
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
    CLLocationCoordinate2D pos = userLocation.coordinate;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(pos,2000, 2000);//以pos为中心，显示2000米
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];//适配map view的尺寸
    [_mapView setRegion:adjustedRegion animated:YES];
    
    [self setMapRoutes];
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        NSLog(@"%@", placemarks[0]);
    }];
    label.text = [NSString stringWithFormat:@"    latitude = %f\n，longitude= %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
