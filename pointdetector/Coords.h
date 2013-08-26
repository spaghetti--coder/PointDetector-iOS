//
//  Coords.h
//  SampleSingleView
//
//  Created by  on 13/07/31.
//  Copyright (c) 2013 Sasaki Ryuta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>

#define BESSEL_A 6377397.155
#define BESSEL_E2 0.00667436061028297
#define BESSEL_MNUM 6334832.10663254

#define GRS80_A 6378137.000
#define GRS80_E2 0.00669438002301188
#define GRS80_MNUM 6335439.32708317

#define WGS84_A 6378137.000
#define WGS84_E2 0.00669437999019758
#define WGS84_MNUM 6335439.32729246

#define BESSEL 0
#define GRS80 1
#define WGS84 2

#define deg2rad(a) ( (a) / 180.0 * M_PI ) // degreeをradianに

// ターゲットのサンプル(JR札幌駅)
#define TARGET_SAPPORO_STA_LAT 43.068623
#define TARGET_SAPPORO_STA_LNG 141.350800

@interface Coords : NSObject

// ヒュベニの公式でm単位で計算して、計算結果を戻り値で返却するメソッド
+ (double) calcDistHubeny:(int)type
             latitudeFrom:(double)latfrom longitudeFrom:(double)lngfrom
               latitudeTo:(double)latto longitudeTo:(double)lngto;

@end
