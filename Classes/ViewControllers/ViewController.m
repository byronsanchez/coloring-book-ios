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

#import "ViewController.h"
#import "AppDelegate.h"

static BOOL sIsFirstLaunch = YES;

// Adds scrollview callback methods to the ViewController class.
@interface ViewController (PrivateMethods)
- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
@end

@implementation ViewController

@synthesize mIbMainSettings = _mIbMainSettings;
@synthesize mIbMainHelp = _mIbMainHelp;
@synthesize mIbPagerLeft = _mIbPagerLeft;
@synthesize mIbPagerRight = _mIbPagerRight;
@synthesize mScrollView = _mScrollView;
@synthesize mDbNodeHelper = _mDbNodeHelper;
@synthesize viewList = _viewList;

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
    
  }
  return self;
}

// Implements viewDidLoad.
- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  
  [self.navigationController setNavigationBarHidden:YES];
  
  /**
   * Database check!
   */
  
  // Probe the database in case installtion or upgrades are necessary.
  _mDbNodeHelper = [[NodeDatabase alloc] init];
  [_mDbNodeHelper createDatabase];
  // On first run, viewWillAppear will populate the pager with
  // data.
  _mCategoryLength = 0;
  [_mDbNodeHelper close];
  
  /**
   * Splash screen on first launch.
   */
  
  if (sIsFirstLaunch) {
    // Launch the credits view.
    
    if (_isTablet) {
      _splashScreenViewController = [[SplashScreenViewController alloc]
                                    initWithNibName:@"SplashScreenViewController_iPad"
                                    bundle:nil];
    }
    else {
      
      if (_isLarge) {
        // iPhone 5+
        _splashScreenViewController = [[SplashScreenViewController alloc] initWithNibName:@"SplashScreenViewController_iPhoneLarge" bundle:nil];
      }
      else {
        // iPhone Classic
        _splashScreenViewController = [[SplashScreenViewController alloc] initWithNibName:@"SplashScreenViewController_iPhone" bundle:nil];
      }
    }
    
    // For backwards compatibility, we are using the navigation controller instead
    // of the modal presenter.
    _splashScreenViewController.mContext = self;
    [self.navigationController pushViewController:_splashScreenViewController animated:NO];
    
    sIsFirstLaunch = NO;
  }
  
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
   * Background layer.
   */
  
  UIImage *imageBackground = [UIImage imageNamed:@"bg"];
  UIImageView *backgroundView = [[UIImageView alloc]
                                 initWithImage:imageBackground];
  backgroundView.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
  [backgroundView setContentMode:UIViewContentModeScaleAspectFill];
  
  [[self view] addSubview:backgroundView];
  
  /**
   * Vector Background layer.
   */
  UIImage *vectorBackground = [UIImage imageNamed:@"vector_background"];
  UIImageView *vectorBackgroundView = [[UIImageView alloc]
                                       initWithImage:vectorBackground];
  vectorBackgroundView.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
  [vectorBackgroundView setContentMode:UIViewContentModeScaleAspectFit];
  
  [[self view] addSubview:vectorBackgroundView];
  
  /**
   * Floor layer.
   */
  
  UIImage *floorImage = [UIImage imageNamed:@"floor"];
  _floorHeight = floorImage.size.height;
  _floorWidth = floorImage.size.width;
  
  UIImageView *floorImageView = [[UIImageView alloc] initWithImage:floorImage];
  // Position the view at the bottom of the screen (totalHeight - floor height
  // on y axis)
  floorImageView.frame = CGRectMake(0,
                                    (_screenHeight - _floorHeight),
                                    _screenWidth,
                                    _floorHeight);
  [floorImageView setContentMode:UIViewContentModeScaleToFill];
  
  // Add to main view.
  [[self view] addSubview:floorImageView];
  
  /**
   * Main title layer.
   */
  
  // Get the top spacing
  CGFloat topSpacing = 0;
  
  if (_isTablet) {
    topSpacing = 30;
  }
  else {
    topSpacing = 12;
  }
  
  UIImage *imageTitle = [UIImage imageNamed:@"main_title"];
  // Store the height locally
  _titleHeight = imageTitle.size.height + topSpacing;
  
  UIImageView *titleView = [[UIImageView alloc] initWithImage:imageTitle];
  // Position the view at the center with top spacing acting as padding/margin.
  // We are currently splitting the top spacing on the top and bottom of the
  // main title.
  titleView.frame = CGRectMake(_screenWidth / 2 - (imageTitle.size.width / 2),
                               (topSpacing / 2),
                               imageTitle.size.width,
                               imageTitle.size.height);
  [titleView setContentMode:UIViewContentModeCenter];
  
  // Add to main view.
  [[self view] addSubview:titleView];
  
  // Calculate the size of the space between the floor and the main title.
  CGFloat resultHeight = (_screenHeight - _floorHeight) - _titleHeight;
  
  /**
   * Algorithms.
   */
  
  // Create a new image object to retrieve the cover size.
  UIImage *coverImage = [UIImage imageNamed:@"cover_1"];
  // Store the width locally
  _mPagerWidth = coverImage.size.width;
  
  // Horizontally center buttons with respect to their available regions.
  
  // To horizontally center while taking the pager width into account, the
  // formula is x = (((1/2)screenwidth - (1/2)pagerWidth) / 2) - (1/2)
  // buttonWidth;
  CGFloat xPosLeft = (((_screenWidth / 2)
                       - (_mPagerWidth / 2)) / 2)
                       - (_mIbPagerLeft.frame.size.width / 2);
  // The right is simply the inverse of the left.
  CGFloat xPosRight = (_screenWidth - xPosLeft)
                      - (_mIbPagerRight.frame.size.width);
  
  // Vertically center the floor buttons with respect to the floor height.
  
  // To vertically center the pager buttons, the formula is y = titleHeight +
  // (1/2) resultHeight + (1/2)button
  CGFloat yPosMain = _titleHeight
                       + ((resultHeight / 2)
                       - (_mIbPagerLeft.frame.size.height / 2));
  // To vertically center the floor buttons, the formula is y = screenWidth -
  // (1/2) floorHeight + (1/2)button
  CGFloat yPosFloor = _screenHeight
                         - ((_floorHeight / 2)
                         + (_mIbMainSettings.frame.size.height / 2));
  
  /**
   * ViewPager
   */
  // width and height values for this view must be floored to prevent retina
  // quirkiness when it halves the true image width and height
  _mScrollView.frame = CGRectMake((_screenWidth / 2)
                                      - (coverImage.size.width / 2),
                                  _titleHeight,
                                  floor(coverImage.size.width),
                                  floor(coverImage.size.height));
  
  /**
   * Buttons
   */
  
  _mIbPagerLeft.frame = CGRectMake(xPosLeft,
                                   yPosMain,
                                   _mIbPagerLeft.frame.size.width,
                                   _mIbPagerLeft.frame.size.height);
  _mIbPagerRight.frame = CGRectMake(xPosRight,
                                    yPosMain,
                                    _mIbPagerRight.frame.size.width,
                                    _mIbMainHelp.frame.size.height);
  
  _mIbMainSettings.frame = CGRectMake(xPosLeft,
                                      yPosFloor,
                                      _mIbMainSettings.frame.size.width,
                                      _mIbMainSettings.frame.size.height);
  _mIbMainHelp.frame = CGRectMake(xPosRight,
                                  yPosFloor,
                                  _mIbMainHelp.frame.size.width,
                                  _mIbMainHelp.frame.size.height);
  
  /**
   * WebView for Help screen.
   */
  
  // If the device is a tablet.
  if (_isTablet) {
    _infoView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 700, 500)];
    _webViewFontSize = 40;
  }
  // If the device is a phone
  else {
    _infoView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
    _webViewFontSize = 16;
  }
  
  // Prevent the white flash
  _infoView.backgroundColor = [UIColor clearColor];
  _infoView.opaque = NO;
  
  // Load the image resource path.
  NSString *path = [[NSBundle mainBundle] bundlePath];
  NSURL *baseUrl = [NSURL fileURLWithPath:path];
  
  // Set font styling.
  UIFont *font = [UIFont systemFontOfSize:_webViewFontSize];
  
  // Populate the text fields with corresponding data from the SQLite
  // database.
  // Set the text size of the webview based on the preference setting.
  [_infoView loadHTMLString:[NSString stringWithFormat:@"<html><head><meta name=\"viewport\" /><style type=\"text/css\"> body {font-family: \"%@\"; font-size: %f;} img {max-width: 100%%; width: auto;}</style></head><body text=\"#FFFFFF\">%@</body></html>", font.familyName, font.pointSize, NSLocalizedString(@"tv_help", nil)] baseURL:baseUrl];
  
  // Create layout params with the calculated sizes.
  [_infoView setContentMode:UIViewContentModeScaleToFill];
  UIScrollView *webScroller = (UIScrollView *) [[_infoView subviews] objectAtIndex:0];
  [webScroller setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
  
  // Hide the shadow images that are default in webviews.
  for (UIView *wview in [[[_infoView subviews] objectAtIndex:0] subviews]) {
    if ([wview isKindOfClass:[UIImageView class]]) {
      wview.hidden = YES;
    }
  }
  
  /**
   * Relayer IB views.
   */
  
  // Bring all button views to the front. We are doing it this way so we can use
  // IB and manage segues from there.
  [[self view] bringSubviewToFront:_mIbMainSettings];
  [[self view] bringSubviewToFront:_mIbMainHelp];
  [[self view] bringSubviewToFront:_mIbPagerLeft];
  [[self view] bringSubviewToFront:_mIbPagerRight];
  [[self view] bringSubviewToFront:_mScrollView];
}


// Implements viewWillAppear.
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!_mDbNodeHelper.mIsUpgradeTaskInProgress) {
    /**
     * Database check!
     */
    
    // Memory manage all variables.
    if (_mDbNodeHelper != nil) {
      _mDbNodeHelper = nil;
    }
    if (_mCategoryData != nil) {
      _mCategoryData = nil;
    }
    
    // Create our database access object.
    _mDbNodeHelper = [[NodeDatabase alloc] init];
    
    // Call the create method right just in case the user has never run the
    // app before. If a database does not exist, the prepopulated one will
    // be copied from the assets folder. Else, a connection is established.
    [_mDbNodeHelper createDatabase];
    
    // Query the database for all purchased categories.
    
    // Set a conditional buffer. Internally, the orderby is set to _id ASC
    // (NodeDatabase.java).
    [_mDbNodeHelper setConditions:@"isAvailable" rightOperand:@"1"];
    // Execute the query.
    _mCategoryData = [_mDbNodeHelper getCategoryListData];
    // Store the number of categories available.
    NSInteger newLength = [_mCategoryData count];
    // Flush the buffer.
    [_mDbNodeHelper flushQuery];
    
    // This activity no longer needs the connection, so close it.
    [_mDbNodeHelper close];
    
    // Only rebuild the pager if there has been a change in length of
    // available categories. This means that the user has purchased a new
    // coloring book!
    if (newLength > _mCategoryLength) {
      _mCategoryLength = newLength;
      // Rebuild the pager.
      [self initializePaging];
      [self updateButtons];
    }
  }
}

- (void)initializePaging {
  
  // Set the ui button images for each control state.
  if (_mCategoryLength == 1) {
    // If the user has not previously bought a pack, make sure to use the
    // disabled images for the normal state so they are clickable for the toast
    // message.
    [_mIbPagerLeft setImage:[UIImage imageNamed:@"button_previous_disabled"]
                   forState:UIControlStateNormal];
    [_mIbPagerRight setImage:[UIImage imageNamed:@"button_next_disabled"]
                    forState:UIControlStateNormal];
    
    // Disable shadow hightlighting
    [_mIbPagerLeft setAdjustsImageWhenHighlighted:NO];
    [_mIbPagerRight setAdjustsImageWhenHighlighted:NO];
    
  }
  else {
    // If the user HAS bought a pack, use the normal enable/disable state
    // images. No toast messages in this case.
    [_mIbPagerLeft setImage:[UIImage imageNamed:@"button_previous"]
                   forState:UIControlStateNormal];
    [_mIbPagerRight setImage:[UIImage imageNamed:@"button_next"]
                    forState:UIControlStateNormal];
    [_mIbPagerLeft setImage:[UIImage imageNamed:@"button_previous_disabled"]
                   forState:UIControlStateDisabled];
    [_mIbPagerRight setImage:[UIImage imageNamed:@"button_next_disabled"]
                    forState:UIControlStateDisabled];
    
    // Enable shadow hightlighting
    [_mIbPagerLeft setAdjustsImageWhenHighlighted:YES];
    [_mIbPagerRight setAdjustsImageWhenHighlighted:YES];
  }
  
  // view controllers are created lazily
  // in the meantime, load the array with placeholders which will be replaced on
  // demand
  NSMutableArray *tempViewList = [[NSMutableArray alloc] init];
  for (NSInteger i = 0; i < _mCategoryLength; i++)
  {
    [tempViewList addObject:[NSNull null]];
  }
  _viewList = tempViewList;
  
  // a page is the width of the scroll view
  _mScrollView.pagingEnabled = YES;
  _mScrollView.contentSize =
      CGSizeMake(_mScrollView.frame.size.width * _mCategoryLength,
                 _mScrollView.frame.size.height);
  _mScrollView.showsHorizontalScrollIndicator = NO;
  _mScrollView.showsVerticalScrollIndicator = NO;
  _mScrollView.scrollsToTop = NO;
  _mScrollView.delegate = self;
  
  _mCurrentItemId = 0;
  
  // pages are created on demand
  // load the visible page
  // load the page on either side to avoid flashes when the user starts
  // scrolling
  [self loadScrollViewWithPage:0];
  [self loadScrollViewWithPage:1];
  
}

// Loads a page to display in the ScrollView.
- (void)loadScrollViewWithPage:(NSInteger)page
{
  if (page < 0)
    return;
  if (page >= _mCategoryLength)
    return;
  
  // replace the placeholder if necessary
  ViewPager *permView = [_viewList objectAtIndex:page];
  if ((NSNull *)permView == [NSNull null])
  {
    
    // Create a new view in which to store one page worth of views.
    permView = [[ViewPager alloc] initWithFrame:_mScrollView.frame];
    
		[_viewList addObject:permView];
    
    [permView setBackgroundColor:[UIColor clearColor]];
    
    [_viewList replaceObjectAtIndex:page withObject:permView];
    
    // Create the button image view
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(onClick:)
     forControlEvents:UIControlEventTouchUpInside];
    NSString *cover = [@"cover_" stringByAppendingFormat:@"%d", (page + 1)];
    [button setImage:[UIImage imageNamed:cover] forState:UIControlStateNormal];
    button.frame =
        CGRectMake(0,
                   0,
                   _mScrollView.frame.size.width,
                   _mScrollView.frame.size.height);
    [button setContentMode:UIViewContentModeScaleAspectFit];
    [button setAutoresizingMask:UIViewAutoresizingNone];
    [button setTag:5];
    
    [permView addSubview:button];
    
    
    // Create the label view
    UILabel *label = [[UILabel alloc]
          initWithFrame:CGRectMake(0,
                                  (_screenHeight - _floorHeight) - _titleHeight,
                                   _mScrollView.frame.size.width,
                                   _floorHeight)];
    Categorie *numberItem = [_mCategoryData objectAtIndex:page];
    label.text = numberItem.category;
    [label setContentMode:UIViewContentModeLeft];
    [label setAutoresizingMask:UIViewAutoresizingNone];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:UITextAlignmentCenter];
    
    // Pass the view controller its corresponding category id (non-zero
    // indexed).
    permView.cid = numberItem.identifier;
    
    if (_isTablet) {
      [label setFont:[UIFont boldSystemFontOfSize:54]];
    }
    else {
      [label setFont:[UIFont boldSystemFontOfSize:22]];
    }
    
    [permView addSubview:label];
  }
  
  // add the controller's view to the scroll view and position it on the proper
  // page
  if (permView.superview == NULL)
  {
    CGRect frame = _mScrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    permView.frame = frame;
    [_mScrollView addSubview:permView];
  }
}

// Invokes page load method calls whenever the user scrolls via the scrollview
// as opposed to buttons.
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
  // We don't want a "feedback loop" between the UIPageControl and the scroll
  // delegate in which a scroll event generated from the user hitting the page
  // control triggers updates from the delegate method. We use a boolean to
  // disable the delegate logic when the page control is used.
  if (_pageControlUsed)
  {
    // do nothing - the scroll was initiated from the page control, not the user
    // dragging
    return;
  }
	
  // Switch the indicator when more than 50% of the previous/next page is
  // visible
  CGFloat pageWidth = _mScrollView.frame.size.width;
  NSInteger page =
      floor((_mScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
  _mCurrentItemId = page;
  
  // load the visible page and the page on either side of it (to avoid flashes
  // when the user starts scrolling)
  [self loadScrollViewWithPage:page - 1];
  [self loadScrollViewWithPage:page];
  [self loadScrollViewWithPage:page + 1];
  
  [self updateButtons];
  
  // A possible optimization would be to unload the views+controllers which are
  // no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls
// originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
  _pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate
// from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  _pageControlUsed = NO;
}

- (void)updateButtons {
  
  NSInteger count;
  
  // Updates are only necessary when there are more than one available
  // categories (prevents state change for clickable disabled button that shows
  // shop toast).
  if (_mCategoryLength > 1) {
    
    /*
     * Left direciton.
     */
    
    // Store the total and subtract one to normalize to zero-index.
    count = _mCategoryLength - 1;
    if (_mCurrentItemId <= 0) {
      _mCurrentItemId = 0;
      
      // Set the button to be disabled.
      [_mIbPagerLeft setEnabled:NO];
      
      // mPager.beginFakeDrag();
      // mPager.fakeDragBy(-25);
      // mPager.endFakeDrag();
    }
    if (_mCurrentItemId == count - 1) {
      // Enable the right pager if the current position is 1 screen away
      // from
      // the final position.
      [_mIbPagerRight setEnabled:YES];
    }
    
    /*
     * Right Direction.
     */
    
    // Store the total and subtract one to normalize to zero-index.
    count = _mCategoryLength - 1;
    if (_mCurrentItemId >= count) {
      
      _mCurrentItemId = _mCategoryLength - 1;
      
      // Set the button to be disabled.
      [_mIbPagerRight setEnabled:NO];
      
      // mPager.beginFakeDrag();
      // mPager.fakeDragBy(25);
      // mPager.endFakeDrag();
    }
    if (_mCurrentItemId == 0 + 1) {
      // Enable the left pager if the current position is 1 screen away
      // from
      // the min (0) position.
      [_mIbPagerLeft setEnabled:YES];
    }
    
  }
}

- (void)loadMusic {
  
  /**
   * Initial Music Check.
   */
  
  // This should only run once at the start of the application.
  if (![MusicManager getIsManualSound]) {
    
    // Update actual status
    [MusicManager updateVolume];
    [MusicManager updateStatusFromPrefs];
    
    // This method can no longer be invoked to turn off the
    // sound once the user has manually turned sound on.
    [MusicManager setIsManualSound:YES];
  }
  
  // Store the preference values in local variables.
  BOOL tbSettingsMusicIsChecked = [Preferences
                                   getPreferenceBool:@"tbSettingsMusicIsChecked"
                                   defaultValue:NO];
  
  // Set whether music is on or not in the Music Manager
  if (tbSettingsMusicIsChecked) {
    [MusicManager start:[MusicManager getMusicA]];
  }
  
}

- (IBAction)onClick:(id)sender
{
  
  // If the user has only the default category...
  if (_mCategoryLength == 1) {
    
    switch ([sender tag]) {
        
        // The previous-pager button
      case 1: {
        [self.view makeToast:@"More coloring book packs are available in the Settings -> Shop screen."
                    duration:3.0
                    position:@"bottom"];
      }
        break;
        
        // The next-pager button
      case 2: {
        
        [self.view makeToast:@"More coloring book packs are available in the Settings -> Shop screen."
                    duration:3.0
                    position:@"bottom"];
        
      }
        
        break;
        
    }
    
  }
  else {
    
    switch ([sender tag]) {
        
        // The previous-pager button
      case 1: {
        _mCurrentItemId--;
        
        // Bound the current item id.
        if (_mCurrentItemId <= 0) {
          _mCurrentItemId = 0;
        }
        
        // load the visible page and the page on either side of it (to avoid
        // flashes when the user starts scrolling)
        [self loadScrollViewWithPage:_mCurrentItemId - 1];
        [self loadScrollViewWithPage:_mCurrentItemId];
        [self loadScrollViewWithPage:_mCurrentItemId + 1];
        
        // update the scroll view to the appropriate page
        CGRect frame = _mScrollView.frame;
        frame.origin.x = frame.size.width * _mCurrentItemId;
        frame.origin.y = 0;
        [_mScrollView scrollRectToVisible:frame animated:YES];
        
        // Set the boolean used when scrolls originate from the UIPageControl.
        // See scrollViewDidScroll: above.
        _pageControlUsed = YES;
        
        [self updateButtons];
        
      }
        break;
        
        // The next-pager button
      case 2: {
        
        _mCurrentItemId++;
        
        // Bound the current item id.
        if (_mCurrentItemId >= _mCategoryLength - 1) {
          _mCurrentItemId = _mCategoryLength - 1;
        }
        
        // load the visible page and the page on either side of it (to avoid
        // flashes when the user starts scrolling)
        [self loadScrollViewWithPage:_mCurrentItemId - 1];
        [self loadScrollViewWithPage:_mCurrentItemId];
        [self loadScrollViewWithPage:_mCurrentItemId + 1];
        
        // update the scroll view to the appropriate page
        CGRect frame = _mScrollView.frame;
        frame.origin.x = frame.size.width * _mCurrentItemId;
        frame.origin.y = 0;
        [_mScrollView scrollRectToVisible:frame animated:YES];

        // Set the boolean used when scrolls originate from the UIPageControl.
        // See scrollViewDidScroll: above.
        _pageControlUsed = YES;
        
        [self updateButtons];
        
      }
        break;
        
        
    }
    
  }
  
  switch ([sender tag]) {
      
      // The settings button.
    case 3: {
      SettingsViewController *settingsViewController;
      
      if (_isTablet) {
        settingsViewController = [[SettingsViewController alloc]
                                  initWithNibName:@"SettingsViewController_iPad"
                                           bundle:nil];
      }
      else {
        
        if (_isLarge) {
          // iPhone 5+
          settingsViewController = [[SettingsViewController alloc]
                          initWithNibName:@"SettingsViewController_iPhoneLarge"
                                   bundle:nil];
        }
        else {
          // iPhone Classic
          settingsViewController = [[SettingsViewController alloc]
                                initWithNibName:@"SettingsViewController_iPhone"
                                         bundle:nil];
        }
      }
      
      [self.navigationController pushViewController:settingsViewController
                                           animated:YES];
    }
      break;
      
      // The Help Button
    case 4: {
      
      [[KGModal sharedInstance] setShowCloseButton:YES];
      [[KGModal sharedInstance] setAnimateWhenDismissed:YES];
      [[KGModal sharedInstance] showWithContentView:_infoView andAnimated:YES];
      [[KGModal sharedInstance] setModalBackgroundColor:
       [Colors colorFromHexString:@"#00163BFF"]];
      [[KGModal sharedInstance] setBackgroundDisplayStyle:
       KGModalBackgroundDisplayStyleSolid];
      
    }
      break;
      
      // The coloring book button
    case 5: {
      ColorViewController *colorViewController;
      
      if (_isTablet) {
        colorViewController = [[ColorViewController alloc]
                               initWithNibName:@"ColorViewController_iPad"
                                        bundle:nil];
      }
      else {
        
        if (_isLarge) {
          // iPhone 5+
          colorViewController = [[ColorViewController alloc]
                              initWithNibName:@"ColorViewController_iPhoneLarge"
                                       bundle:nil];
        }
        else {
          // iPhone Classic
          colorViewController = [[ColorViewController alloc]
                                 initWithNibName:@"ColorViewController_iPhone"
                                          bundle:nil];
        }
        
      }
      
      // Get the current page view
      ViewPager *selectedPager = [_viewList objectAtIndex:_mCurrentItemId];
      
      // Pass the pager's corresponding category id to the destView.
      colorViewController.mCid = selectedPager.cid;
      
      [self.navigationController pushViewController:colorViewController
                                           animated:YES];
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
