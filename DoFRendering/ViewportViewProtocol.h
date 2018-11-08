//
//  ViewportViewProtocol.h
//  MBE
//
//  Created by Bartłomiej Nowak on 08/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#ifndef ViewportViewProtocol_h
#define ViewportViewProtocol_h

#import "SliderStackViewModel.h"

@protocol ViewportViewProtocol <NSObject>
- (void)presentSliders:(SliderStackViewModel*)viewModel;
@end

#endif /* ViewportViewProtocol_h */
