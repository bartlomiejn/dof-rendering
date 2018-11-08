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

@interface ViewportViewController : UIViewController<ViewportViewProtocol>
@property (nonatomic, strong) ViewportPresenter *presenter;
@end

