//
//  BannerView.m
//  AirFlurry
//
//  Created by Toine on 11/03/2014.
//
//

#import "BannerView.h"
#import "AirFlurry.h"

@implementation BannerView

@synthesize space;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    }

    return self;
}

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
    [[AirFlurry sharedInstance] adDidRender:self.space];
}

- (void)willRemoveSubview:(UIView *)subview {
    [super willRemoveSubview:subview];
    NSLog(@"[Flurry] Banner view : Will remove subview.");
}

@end

