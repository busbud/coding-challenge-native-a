//
//  Config.h
//  BusBud
//
//  Created by Chris Comeau on 2014-11-03.
//  Copyright (c) 2014 Skyriser Media. All rights reserved.
//

#ifndef BusBud_Config_h
#define BusBud_Config_h

//color
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kColorBlue RGB(33,121,190)
#define kColorBlueCell RGBA(33,121,190, 0.2f)
#define kColorPlaceholder RGB(159,203,243)
#define kButtonTitleOffset 34

//API

#define kDefaultLanguage @"en"
#define kAPISearch @"https://www.busbud.com/%@/bus-schedules/%@/%@"


#endif
