static BOOL isUpdatingGracePeriod;

%hook PasscodeLockController
- (void)updateGracePeriodSpecifier
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
