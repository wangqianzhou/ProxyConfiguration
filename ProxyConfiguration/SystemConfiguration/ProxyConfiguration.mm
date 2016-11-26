//
//  ProxyConfiguration.c
//  ProxyConfiguration
//
//  Created by wangqianzhou on 26/11/2016.
//  Copyright © 2016 alibaba-inc. All rights reserved.
//

#include "ProxyConfiguration.h"

extern "C" {
    
    typedef const struct __SCPreferences* SCPreferencesRef;
    typedef const struct AuthorizationOpaqueRef* AuthorizationRef;
    
    SCPreferencesRef SCPreferencesCreate(CFAllocatorRef allocator, CFStringRef name, CFStringRef prefsID);
    SCPreferencesRef SCPreferencesCreateWithAuthorization(CFAllocatorRef allocator, CFStringRef name, CFStringRef prefsID, AuthorizationRef authorization);
    CFPropertyListRef SCPreferencesGetValue(SCPreferencesRef prefs, CFStringRef key);
    Boolean SCPreferencesPathSetValue(SCPreferencesRef prefs, CFStringRef path, CFDictionaryRef value);
    Boolean SCPreferencesCommitChanges(SCPreferencesRef prefs);
    Boolean SCPreferencesApplyChanges(SCPreferencesRef prefs);
    void SCPreferencesSynchronize(SCPreferencesRef prefs);
}

@interface ProxyConfigurationUtils ()

+ (BOOL)setProxyWithConfiguration:(CFMutableDictionaryRef)proxyConfiguration;

@end

@implementation ProxyConfigurationUtils

+ (BOOL)setProxyWithConfiguration:(CFMutableDictionaryRef)proxyConfiguration
{
    BOOL result = NO;
    do
    {
        if (proxyConfiguration == nil)
        {
            break ;
        }
        
        SCPreferencesRef pref = SCPreferencesCreateWithAuthorization(kCFAllocatorDefault, CFSTR("PrettyTunnel"), NULL, NULL);
        if (pref == nil)
        {
            break ;
        }

        CFPropertyListRef services = SCPreferencesGetValue(pref, CFSTR("NetworkServices"));
        NSDictionary* servicesDict = (__bridge NSDictionary*)services;
        if (servicesDict == nil || ![servicesDict isKindOfClass:[NSDictionary class]])
        {
            break;
        }

        NSDictionary* mServicesDict = [servicesDict copy];
        [mServicesDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSDictionary* configDict = (NSDictionary*)obj;
            if ([configDict isKindOfClass:[NSDictionary class]]) {
                NSString* rank = [configDict objectForKey:@"PrimaryRank"];
                if (rank != nil && ![rank isEqualToString:@"Never"]) {
                    NSString* path = [NSString stringWithFormat:@"/NetworkServices/%@/Proxies", key];
                    SCPreferencesPathSetValue(pref, (__bridge CFStringRef)path, proxyConfiguration);
                }
            }
        }];
        
        if (SCPreferencesCommitChanges(pref))
        {
            break ;
        }
        
        if (SCPreferencesApplyChanges(pref))
        {
            break;
        }
        
        SCPreferencesSynchronize(pref);
        result = YES;
        
    } while (0);
    
    return result;
}

+ (BOOL)setProxyWithHost:(NSString*)host port:(NSUInteger)port
{
    CFMutableDictionaryRef configuration = [self getProxyConfigurationWithHost:host port:port];
    
    return [self setProxyWithConfiguration:configuration];
}

+ (BOOL)disableProxy
{
    CFMutableDictionaryRef configuration = [self getEmptyProxyConfiguration];
    
    return [self setProxyWithConfiguration:configuration];
}

+ (CFMutableDictionaryRef)getProxyConfigurationWithHost:(NSString*)host port:(NSUInteger) port
{
    if ([host length] == 0 )
    {
        assert(false);
        return nil;
    }
    
    
    NSMutableDictionary* proxyConfiguration = [NSMutableDictionary dictionaryWithCapacity:4];
    
    NSArray* exceptions = @[@"127.0.0.1", @"localhost"];
    [proxyConfiguration setObject:exceptions forKey:@"ExceptionsList"];
    
    [proxyConfiguration setObject:@(1) forKey:@"SOCKSEnable"];
    [proxyConfiguration setObject:host forKey:@"SOCKSProxy"];
    [proxyConfiguration setObject:@(port) forKey:@"SOCKSPort"];
    
    return (__bridge CFMutableDictionaryRef)proxyConfiguration;
}

+ (CFMutableDictionaryRef)getEmptyProxyConfiguration
{
    NSMutableDictionary* proxyConfiguration = [NSMutableDictionary dictionaryWithCapacity:4];
    [proxyConfiguration setObject:@(1) forKey:@"HTTPEnable"];
    [proxyConfiguration setObject:@(1) forKey:@"HTTPProxyType"];
    [proxyConfiguration setObject:@(1) forKey:@"HTTPSEnable"];
    [proxyConfiguration setObject:@(1) forKey:@"ProxyAutoConfigEnable"];
    
    return (__bridge CFMutableDictionaryRef)proxyConfiguration;
}
@end


