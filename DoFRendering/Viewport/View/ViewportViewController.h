//
//  ViewportViewController.h
//  MBE
//
//  Created by Bartłomiej Nowak on 03/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

@import UIKit;
#import "ViewportPresenter.h"
#import "ViewportViewProtocol.h"
#import "MetalViewDelegate.h"

@interface ViewportViewController : UIViewController<ViewportViewProtocol, MetalViewDelegate>
@property (nonatomic, strong) ViewportPresenter *presenter;
@end

