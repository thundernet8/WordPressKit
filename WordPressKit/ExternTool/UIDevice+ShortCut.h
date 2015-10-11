//
//  UIDevice+ShortCut.h
//  ShourCut
//
//  Created by mac  on 14-1-14.
//  Copyright (c) 2014年 Sky. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 @"i386"      on the simulator
 @"iPod1,1"   on iPod Touch
 @"iPod2,1"   on iPod Touch Second Generation
 @"iPod3,1"   on iPod Touch Third Generation
 @"iPod4,1"   on iPod Touch Fourth Generation
 @"iPod5,1"   on iPod Touch Fifth Generation
 @"iPhone1,1" on iPhone
 @"iPhone1,2" on iPhone 3G
 @"iPhone2,1" on iPhone 3GS
 @"iPad1,1"   on iPad
 @"iPad2,1"   on iPad 2
 @"iPad3,1"   on 3rd Generation iPad
 @"iPad3,2":  on iPad 3(GSM+CDMA)
 @"iPad3,3":  on iPad 3(GSM)
 @"iPad3,4":  on iPad 4(WiFi)
 @"iPad3,5":  on iPad 4(GSM)
 @"iPad3,6":  on iPad 4(GSM+CDMA)
 @"iPhone3,1" on iPhone 4
 @"iPhone4,1" on iPhone 4S
 @"iPhone5,1" on iPhone 5
 @"iPad3,4"   on 4th Generation iPad
 @"iPad2,5"   on iPad Mini
 @"iPhone5,1" on iPhone 5(GSM)
 @"iPhone5,2" on iPhone 5(GSM+CDMA)
 @"iPhone5,3  on iPhone 5c(GSM)
 @"iPhone5,4" on iPhone 5c(GSM+CDMA)
 @"iPhone6,1" on iPhone 5s(GSM)
 @"iPhone6,2" on iPhone 5s(GSM+CDMA)
 @"iPhone7,2" on iPhone 6(GSM+CDMA)
 @"iPhone7,1" on iPhone 7(GSM+CDMA)
 */


@interface UIDevice (ShortCut)


/**
 *   返回设备是否Retina
 *
 *  @return YES, NO
 */
- (BOOL) isRetina;
/**
 *   返回设备是否是ipad或ipad mini
 *
 *  @return YES, NO
 */
- (BOOL) isPad;
/**
 *   返回是否是模拟器
 *
 *  @return YES, NO
 */
- (BOOL) isSimulator;
/**
 *   返回设备是否越狱
 *
 *  @return YES, NO
 */
- (BOOL) isJailbreake;
- (BOOL)isOS4;
- (BOOL)isOS5;
- (BOOL)isOS6;
- (BOOL)isOS7;
-(BOOL)isOS8;

/**
 *  大于IOS7(特殊处理，因为犹豫IOS7以后风格大变)
 *
 *  @return
 */
-(BOOL)isGreaterThanOS7;



/**
 *  返回机型
 *
 *  @return
 */
- (NSString*)machine;



/**
 *  返回设备的mac地址 AA:BB:CC:DD:EE:FF
 */
@property (nonatomic,strong, readonly) NSString *macAddress;
/**
 *   返回当前的ip地址  192.168.1.1
 */
@property (nonatomic,strong, readonly) NSString *ipAddress;
/**
 *  返回当前设备可用内存,的字节数, 返回-1发生错误
 */
@property (nonatomic, readonly) int64_t availableMemory;

@end