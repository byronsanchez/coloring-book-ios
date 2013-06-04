//
// Copyright (c) 2013 Byron Sanchez (hackbytes.com)
// www.chompix.com
//
// This file is part of "Coloring Book for iOS."
//
// "Coloring Book for iOS" is free software: you can redistribute
// it and/or modify it under the terms of the GNU General Public
// License as published by the Free Software Foundation, version
// 2 of the License.
//
// "Coloring Book for iOS" is distributed in the hope that it will
// be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with "Coloring Book for iOS."  If not, see
// <http://www.gnu.org/licenses/>.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize _mButtonMusic;

// Implements init.
- (id)init {
  self = [super init];
  
  if (self) {
    // Init code here.
    
  }
  return self;
}

// Main initializer for the ViewController.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

// Implements viewDidLoad.
- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  
  /*
   * This screen needs to be dynamically positioned to fit each screen
   * size fluidly.
   */
  
  // Get the screen metrics.
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  
  // Use standard metrics. Autoresizing masks will take care of orientation
  // changes.
  _screenWidth = screenRect.size.height;
  _screenHeight = screenRect.size.width;
  
  // DETERMINE DEVICE TYPE
  NSInteger device = UI_USER_INTERFACE_IDIOM();
  
  // Set defaults
  _isTablet = NO;
  _isLarge = NO;
  
  switch (device) {
    case UIUserInterfaceIdiomPhone: {
      if (_screenHeight == 480) {
        
        // iPhone Classic
        _isLarge = NO;
        
      }
      if (_screenHeight == 568) {
        _isLarge = YES;
      }
    }
      break;
      
    case UIUserInterfaceIdiomPad: {
      _isTablet = YES;
    }
      break;
  }
  
  
  /**
   * UI Elements.
   */
  
  // Set the view background color.
  [[self view] setBackgroundColor:[Colors colorFromHexString:@"#00163BFF"]];
  
  
  // ALGORITHMS
  
  UIFont *titleFont;
  UIFont *rowFont;
  
  CGFloat titlePadding;
  CGFloat titleMargin;
  CGFloat rowPadding;
  CGFloat rowMargin;
  
  if (_isTablet) {
    titlePadding = 20;
    titleMargin = 54;
    titleFont = [UIFont boldSystemFontOfSize:54];
    
    rowPadding = 20;
    rowMargin = 80;
    rowFont = [UIFont systemFontOfSize:40];
  }
  else {
    titlePadding = 8;
    titleMargin = 22;
    titleFont = [UIFont boldSystemFontOfSize:22];
    
    rowPadding = 8;
    rowMargin = 32;
    rowFont = [UIFont systemFontOfSize:16];
  }
  
  CGFloat titleHeight = titleFont.pointSize + (titleMargin * 2) + (titlePadding * 2);
  // First button must be declared early to determine button size.
  UIImage *musicButtonImagePlay = [UIImage imageNamed:@"button_play"];
  CGFloat rowHeight = MAX((rowFont.pointSize + rowPadding * 2),
                          musicButtonImagePlay.size.height + (rowPadding * 2));
  CGFloat rowXOffsetLabel = rowMargin;
  CGFloat rowXOffsetButton = (_screenWidth) - rowMargin;
  
  
  // RETURN BUTTON
  UIImage *returnButtonImage = [UIImage imageNamed:@"button_return"];
  
  // Set padding for the return button and progress indicator.
  CGFloat returnButtonY = (titleHeight / 2) - (returnButtonImage.size.height / 2);
  CGFloat returnButtonX = rowXOffsetLabel;
  
  // Return button.
  UIButton *_mIbReturn = [UIButton buttonWithType:UIButtonTypeCustom];
  [_mIbReturn addTarget:self
                 action:@selector(onClick:)
       forControlEvents:UIControlEventTouchUpInside];
  [_mIbReturn setImage:returnButtonImage forState:UIControlStateNormal];
  [_mIbReturn setAlpha:1.0];
  _mIbReturn.frame = CGRectMake(returnButtonX,
                                returnButtonY,
                                returnButtonImage.size.width,
                                returnButtonImage.size.height);
  [_mIbReturn setContentMode:UIViewContentModeScaleAspectFit];
  [_mIbReturn setAutoresizingMask:UIViewAutoresizingNone];
  [_mIbReturn setTag:13];
  
  [[self view] addSubview:_mIbReturn];
  
  // TITLE LABEL
  
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  _screenWidth,
                                                                  titleHeight)];
  titleLabel.text = NSLocalizedString(@"tv_settings_label", nil);
  [titleLabel setContentMode:UIViewContentModeLeft];
  [titleLabel setAutoresizingMask:UIViewAutoresizingNone];
  [titleLabel setTextColor:[UIColor whiteColor]];
  [titleLabel setBackgroundColor:[UIColor clearColor]];
  [titleLabel setTextAlignment:UITextAlignmentCenter];
  [titleLabel setFont:titleFont];
  
  [[self view] addSubview:titleLabel];
  
  
  // MUSIC LABEL
  
  UILabel *musicLabel = [[UILabel alloc] initWithFrame:CGRectMake(rowXOffsetLabel,
                                                                  (rowHeight * 0) + titleHeight,
                                                                  _screenWidth,
                                                                  rowHeight)];
  musicLabel.text = NSLocalizedString(@"tv_settings_music_label", nil);
  [musicLabel setContentMode:UIViewContentModeLeft];
  [musicLabel setAutoresizingMask:UIViewAutoresizingNone];
  [musicLabel setTextColor:[UIColor whiteColor]];
  [musicLabel setBackgroundColor:[UIColor clearColor]];
  [musicLabel setTextAlignment:UITextAlignmentLeft];
  [musicLabel setFont:rowFont];
  
  [[self view] addSubview:musicLabel];
  
  
  UIButton *musicButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [musicButton addTarget:self
                  action:@selector(onClick:)
        forControlEvents:UIControlEventTouchUpInside];
  //UIImage *musicButtonImageStop = [UIImage imageNamed:@"button_stop"];
  [musicButton setImage:musicButtonImagePlay forState:UIControlStateNormal];
  //[musicButton setImage:musicButtonImageStop forState:UIControlStateSelected];
  
  musicButton.frame = CGRectMake(rowXOffsetButton - musicButtonImagePlay.size.width,
                                 (rowHeight * 0) + titleHeight,
                                 musicButtonImagePlay.size.width,
                                 rowHeight);
  [musicButton setContentMode:UIViewContentModeScaleAspectFit];
  [musicButton setAutoresizingMask:UIViewAutoresizingNone];
  [musicButton setTag:6];
  [musicButton setSelected:NO];
  
  [[self view] addSubview:musicButton];
  
  // Create a reference to this via via an instance variable.
  _mButtonMusic = musicButton;
  
  
  // SHOP LABEL
  
  UILabel *shopLabel = [[UILabel alloc] initWithFrame:CGRectMake(rowXOffsetLabel,
                                                                 (rowHeight * 1) + titleHeight,
                                                                 _screenWidth,
                                                                 rowHeight)];
  shopLabel.text = NSLocalizedString(@"tv_settings_shop_label", nil);
  [shopLabel setContentMode:UIViewContentModeLeft];
  [shopLabel setAutoresizingMask:UIViewAutoresizingNone];
  [shopLabel setTextColor:[UIColor whiteColor]];
  [shopLabel setBackgroundColor:[UIColor clearColor]];
  [shopLabel setTextAlignment:UITextAlignmentLeft];
  [shopLabel setFont:rowFont];
  
  [[self view] addSubview:shopLabel];
  
  
  UIButton *shopButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [shopButton addTarget:self
                 action:@selector(onClick:)
       forControlEvents:UIControlEventTouchUpInside];
  UIImage *shopButtonImage = [UIImage imageNamed:@"button_next"];
  [shopButton setImage:shopButtonImage forState:UIControlStateNormal];
  shopButton.frame = CGRectMake(rowXOffsetButton - shopButtonImage.size.width,
                                (rowHeight * 1) + titleHeight,
                                shopButtonImage.size.width,
                                rowHeight);
  [shopButton setContentMode:UIViewContentModeScaleAspectFit];
  [shopButton setAutoresizingMask:UIViewAutoresizingNone];
  [shopButton setTag:7];
  
  [[self view] addSubview:shopButton];
  
  // Create a reference to this via via an instance variable.
  _mButtonShop = shopButton;
  
  // CREDITS LABEL
  
  
  UILabel *creditsLabel = [[UILabel alloc] initWithFrame:CGRectMake(rowXOffsetLabel,
                                                                    (rowHeight * 2) + titleHeight,
                                                                    _screenWidth,
                                                                    rowHeight)];
  creditsLabel.text = NSLocalizedString(@"tv_settings_credits_label", nil);
  [creditsLabel setContentMode:UIViewContentModeLeft];
  [creditsLabel setAutoresizingMask:UIViewAutoresizingNone];
  [creditsLabel setTextColor:[UIColor whiteColor]];
  [creditsLabel setBackgroundColor:[UIColor clearColor]];
  [creditsLabel setTextAlignment:UITextAlignmentLeft];
  [creditsLabel setFont:rowFont];
  
  [[self view] addSubview:creditsLabel];
  
  
  UIButton *creditsButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [creditsButton addTarget:self
                    action:@selector(onClick:)
          forControlEvents:UIControlEventTouchUpInside];
  UIImage *creditsButtonImage = [UIImage imageNamed:@"button_next"];
  [creditsButton setImage:creditsButtonImage forState:UIControlStateNormal];
  creditsButton.frame = CGRectMake(rowXOffsetButton - creditsButtonImage.size.width,
                                   (rowHeight * 2) + titleHeight,
                                   creditsButtonImage.size.width,
                                   rowHeight);
  [creditsButton setContentMode:UIViewContentModeScaleAspectFit];
  [creditsButton setAutoresizingMask:UIViewAutoresizingNone];
  [creditsButton setTag:8];
  
  [[self view] addSubview:creditsButton];
  
  // Create a reference to this via via an instance variable.
  _mButtonCredits = creditsButton;
  
  // Update output based on stored preferences, if any.
  [self updateView];
  
}

- (void)updateView {
  
  // Store the preference values in local variables.
  BOOL tbSettingsMusicIsChecked = [Preferences getPreferenceBool:@"tbSettingsMusicIsChecked"
                                                    defaultValue:NO];
  
  // Update the tbSettingsMusic Toggle Button.
  // This is needed for the initial loading of this view. In manual
  // selections, it's redundant.
  _mButtonMusic.selected = tbSettingsMusicIsChecked;
  
  // Update the default image. Doing it through selection triggers is a lot more
  // tweaking for our specific use (we'd have to change the highlighted image
  // state, tint, etc.). This is much simpler.
  if (_mButtonMusic.selected == NO) {
    [_mButtonMusic setImage:[UIImage imageNamed:@"button_play"]
                   forState:UIControlStateNormal];
  }
  else {
    [_mButtonMusic setImage:[UIImage imageNamed:@"button_stop"]
                   forState:UIControlStateNormal];
  }
  
  // Update actual status
  [MusicManager updateVolume];
  [MusicManager updateStatusFromPrefs];
  
  // Set whether music is on or not in the Music Manager
  if (tbSettingsMusicIsChecked) {
    [MusicManager start:[MusicManager getMusicA]];
  }
  else {
    [MusicManager releaseData];
  }
  
}

- (IBAction)onClick:(id)sender {
  
  switch ([sender tag]) {
      
      // Music Button
    case 6: {
      // Set the music toggle preference to be the opposite of what it
      // currently is.
      _mButtonMusic.selected = !(_mButtonMusic.selected);
      
      [Preferences setPreferenceBool:@"tbSettingsMusicIsChecked"
                               value:_mButtonMusic.selected];
      
      // Update the preview based on the new preference.
      [self updateView];
    }
      
      break;
      
      // Shop Button
    case 7: {
      // Launch the shop view.
      ShopViewController *shopViewController;
      
      if (_isTablet) {
        shopViewController = [[ShopViewController alloc] initWithNibName:@"ShopViewController_iPad"
                                                                        bundle:nil];
      }
      else {
        
        if (_isLarge) {
          // iPhone 5+
          shopViewController = [[ShopViewController alloc] initWithNibName:@"ShopViewController_iPhoneLarge"
                                                                          bundle:nil];
        }
        else {
          // iPhone Classic
          shopViewController = [[ShopViewController alloc] initWithNibName:@"ShopViewController_iPhone"
                                                                          bundle:nil];
        }
      }
      
      [self.navigationController pushViewController:shopViewController
                                           animated:YES];
    }
      
      break;
      
      // Credits Button
    case 8: {
      // Launch the credits view.
      CreditsViewController *creditsViewController;
      
      if (_isTablet) {
        creditsViewController = [[CreditsViewController alloc] initWithNibName:@"CreditsViewController_iPad"
                                                                        bundle:nil];
      }
      else {
        
        if (_isLarge) {
          // iPhone 5+
          creditsViewController = [[CreditsViewController alloc] initWithNibName:@"CreditsViewController_iPhoneLarge"
                                                                          bundle:nil];
        }
        else {
          // iPhone Classic
          creditsViewController = [[CreditsViewController alloc] initWithNibName:@"CreditsViewController_iPhone"
                                                                          bundle:nil];
        }
      }
      
      [self.navigationController pushViewController:creditsViewController
                                           animated:YES];
    }
      
      break;
      
      // The return button.
    case 13: {
      
      [self.navigationController popViewControllerAnimated:YES];
      
    }
      
      break;
  }
  
}

// Implements viewDidUnload.
- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

// Returns whether or not a UI orientation change should occur based on the
// current physical device orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
