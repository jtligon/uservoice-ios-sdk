//
//  UVTruncatingLabel.m
//  UserVoice
//
//  Created by Austin Taylor on 12/4/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVTruncatingLabel.h"
#import "UVDefines.h"

@implementation UVTruncatingLabel

@synthesize fullText;
@synthesize delegate;
@synthesize moreLabel;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandAndNotify)] autorelease]];
        self.moreLabel = [[[UILabel alloc] init] autorelease];
        moreLabel.text = NSLocalizedStringFromTable(@"more", @"UserVoice", nil);
        moreLabel.font = [UIFont systemFontOfSize:12];
        moreLabel.backgroundColor = [UIColor clearColor];
        if (IOS7) {
            moreLabel.textColor = self.tintColor;
        }
        // TODO hardcode blue for ios6 ??
        moreLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:moreLabel];
        NSDictionary *views = @{@"more":moreLabel};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[more]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[more]|" options:0 metrics:nil views:views]];
    }
    return self;
}

- (void)setFullText:(NSString *)theText {
    [fullText release];
    fullText = [theText retain];
    [self update];
}

- (void)update {
    if (!fullText || self.effectiveWidth == 0) return;
    self.text = fullText;
    lastWidth = self.effectiveWidth;
    if (expanded) {
        moreLabel.hidden = YES;
    } else {
        NSArray *lines = [self breakString];
        if ([lines count] > 3) {
            CGSize moreSize = [moreLabel intrinsicContentSize];
            self.text = [NSString stringWithFormat:@"%@%@%@", [lines objectAtIndex:0], [lines objectAtIndex:1], [lines objectAtIndex:2]];
            int i = [self.text length] - 1;
            CGRect r = [self rectForLetterAtIndex:i];
            while (self.effectiveWidth - r.origin.x - r.size.width < (20 + moreSize.width) && i > 0) {
                i--;
                r = [self rectForLetterAtIndex:i];
            }
            self.text = [NSString stringWithFormat:@"%@...", [self.text substringWithRange:NSMakeRange(0, i+1)]];
            moreLabel.hidden = NO;
        } else {
            moreLabel.hidden = YES;
        }
    }
}

- (CGSize)intrinsicContentSize {
    [self update];
    return [super intrinsicContentSize];
}

- (CGFloat)effectiveWidth {
    return MAX(self.frame.size.width, self.preferredMaxLayoutWidth) - 4;
}

- (void)layoutSubviews {
    if (lastWidth != self.effectiveWidth) {
        [self update];
    }
    [super layoutSubviews];
}

- (void)expandAndNotify {
    [self expand];
    [delegate performSelector:@selector(labelExpanded:) withObject:self];
}

- (void)expand {
    expanded = YES;
    [self update];
}

- (void)dealloc {
    self.fullText = nil;
    self.moreLabel = nil;
    [super dealloc];
}

@end
