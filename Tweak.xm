#import <Preferences/Preferences.h>
#import <ColorLog.h>

static BOOL isUpdatingGracePeriod;
static NSNumber * const neverPeriod = @(5);

%group Preferences // for display default and never grace period list. {{{
%hook PasscodeLockController
// iOS 7.0.x
- (void)updateGracePeriodSpecifier
{
    isUpdatingGracePeriod = YES;
    %orig;
    isUpdatingGracePeriod = NO;
}
// iOS 7.1+
- (void)_updateGracePeriodForSpecifier:(PSSpecifier *)specifier
{
    isUpdatingGracePeriod = YES;
    %orig;
    isUpdatingGracePeriod = NO;

    // Add never period.
    NSString * const title = @"Never!"; 

    NSMutableArray *values = [specifier.values mutableCopy];
    [values addObject:neverPeriod];
    specifier.values = [NSArray arrayWithArray:values];
    [values release];

    NSMutableDictionary *titleDictionary = [specifier.titleDictionary mutableCopy];
    titleDictionary[neverPeriod] = title;
    specifier.titleDictionary = [NSDictionary dictionaryWithDictionary:titleDictionary];
    [titleDictionary release];

    NSMutableDictionary *shortTitleDictionary = [specifier.shortTitleDictionary mutableCopy];
    shortTitleDictionary[neverPeriod] = title;
    specifier.shortTitleDictionary = [NSDictionary dictionaryWithDictionary:shortTitleDictionary];
    [shortTitleDictionary release];
}
// getter of specifier.
- (NSNumber *)graceValue:(PSSpecifier *)specifier
{
    NSNumber *tmp = %orig;
    if ([tmp isEqualToNumber:@(INT_MAX)]) {
        return neverPeriod;
    }
    return tmp;
}
%end

%hook PSBiometricIdentity 
+ (NSArray *)identities
{
    return isUpdatingGracePeriod ? nil : %orig;
}
%end
%end // Preference
// }}}
%group profiled // {{{
%hook MCServerSideHacks
- (void)applyEffectiveSettings:(NSDictionary *)dict toOtherSubsystemsPasscode:(id)passcode
{
    NSNumber *val = dict[@"restrictedValue"][@"maxGracePeriod"][@"value"];
    CMLog(@"val = %@", val);
    if ([val isEqualToNumber:neverPeriod]) {
        NSMutableDictionary *d = [dict mutableCopy];
        d[@"restrictedValue"][@"maxGracePeriod"][@"value"] = @(INT_MAX);
        %orig([NSDictionary dictionaryWithDictionary:d], passcode);
        [d release];
        return;
    }
    %orig;
}
%end
%end // profiled }}}
%ctor // Constructor {{{
{
    @autoreleasepool {
        NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
        if ([bundleIdentifier isEqualToString:@"com.apple.Preferences"]) {
            %init(Preferences);
        } else {
            %init(profiled);
        }
    }
}
// }}}

// vim: set fdm=marker: 
