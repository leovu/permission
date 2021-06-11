#import "PermissionPlugin.h"
#if __has_include(<permission/permission-Swift.h>)
#import <permission/permission-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "permission-Swift.h"
#endif

@implementation PermissionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPermissionPlugin registerWithRegistrar:registrar];
}
@end
