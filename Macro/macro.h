//
//  macro.h
//  Mengniu3rd
//
//  Created by curer on 8/28/13.
//  Copyright (c) 2013 curer. All rights reserved.
//

#ifndef Mengniu3rd_macro_h
#define Mengniu3rd_macro_h

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < 2.2204460492503131e-16 )
#define IPHONE5_OFFSET 88.0

#define ASSET_BY_SCREEN_HEIGHT(regular, longScreen) (([[UIScreen mainScreen] bounds].size.height <= 480.0) ? regular : longScreen)


#ifndef RGB
#define RGB(r, g, b) \
[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#endif

#define DESIGNRECT(left, top ,width ,height) \
CGRectMake((left)/2.0, (top)/2.0, (width)/2.0, (height)/2.0);

#define WIDTH(view) view.frame.size.width
#define HEIGHT(view) view.frame.size.height
#define LEFT(view) view.frame.origin.x
#define TOP(view) view.frame.origin.y
#define BOTTOM(view) (view.frame.origin.y + view.frame.size.height)
#define RIGHT(view) (view.frame.origin.x + view.frame.size.width)

#define MutiLanguage(text) NSLocalizedStringFromTable((text),@"mm", nil)

typedef void (^action_block_t)(void);

typedef void (^CUBlockHandler)(BOOL bSucceed);

typedef void (^CUNetBlockHandler)(BOOL bSucceed, NSDictionary *data);

#define IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define ABOVE_IOS6 IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")

#define IS_CHINESE ([MutiLanguage(@"isSampleChinese") isEqualToString:@"YES"])

#endif
