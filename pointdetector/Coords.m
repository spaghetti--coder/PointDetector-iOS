//
//  Coords.m
//  SampleSingleView
//
//  Created by  on 13/07/31.
//  Copyright (c) 2013 Sasaki Ryuta. All rights reserved.
//

#import "Coords.h"

@implementation Coords

+ (double) calcDistHubeny:(int)type
             latitudeFrom:(double)latfrom longitudeFrom:(double)lngfrom
               latitudeTo:(double)latto longitudeTo:(double)lngto
{
    
    double a, e2, mnum;
    
    // 選択された測位系ごとに、必要なパラメータを設定
    switch (type) {
        case BESSEL:
            a = BESSEL_A;
            e2 = BESSEL_E2;
            mnum = BESSEL_MNUM;
            break;
        case WGS84:
            a = WGS84_A;
            e2 = WGS84_E2;
            mnum = WGS84_MNUM;
            break;
        default:
            a = GRS80_A;
            e2 = GRS80_E2;
            mnum = GRS80_MNUM;
    }
    
    double my = deg2rad((latfrom + latto) / 2.0);
    double dy = deg2rad(latfrom - latto);
    double dx = deg2rad(lngfrom - lngto);
    
    double s = sin(my);
    double w = sqrt(1.0 - e2 * s * s);
    double m = mnum / (w * w * w);
    double n = a / w;
    
    double dym = dy * m;
    double dxncos = dx * n * cos(my);
    
    return sqrt(dym * dym + dxncos * dxncos);
    
}

@end
