//
//  GeneralPrefsPanel.h
//  Bubble
//
//  Created by Luke on 11/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SS_PreferencePaneProtocol.h"

@interface GeneralPrefsPanel : NSObject<SS_PreferencePaneProtocol> {
	IBOutlet NSView *prefsView;
}

@end
