#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view.backgroundColor = [UIColor systemBackgroundColor];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Rigs of Rods iOS\n\nApp shell is running.\nThe game engine is not connected yet.";
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    label.textColor = [UIColor labelColor];
    [viewController.view addSubview:label];

    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:viewController.view.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:viewController.view.centerYAnchor],
        [label.leadingAnchor constraintGreaterThanOrEqualToAnchor:viewController.view.leadingAnchor constant:24.0],
        [label.trailingAnchor constraintLessThanOrEqualToAnchor:viewController.view.trailingAnchor constant:-24.0]
    ]];

    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
