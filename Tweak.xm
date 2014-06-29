static BOOL isUpdatingGracePeriod;

%hook PasscodeLockController
// iOS 7.0.x
- (void)updateGracePeriodSpecifier
{
    isUpdatingGracePeriod = YES;
    %orig;
    isUpdatingGracePeriod = NO;
}
// iOS 7.1+
- (void)_updateGracePeriodForSpecifier:(id)arg1
{
    isUpdatingGracePeriod = YES;
    %orig;
    isUpdatingGracePeriod = NO;
}
%end

%hook PSBiometricIdentity 
+ (NSArray *)identities
{
    return isUpdatingGracePeriod ? nil : %orig;
}
%end
