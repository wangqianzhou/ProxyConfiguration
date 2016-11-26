//
//  ProxyConfiguration.h
//  ProxyConfiguration
//
//  Created by wangqianzhou on 26/11/2016.
//  Copyright © 2016 alibaba-inc. All rights reserved.
//

#ifndef ProxyConfiguration_h
#define ProxyConfiguration_h

#import <Foundation/Foundation.h>

@interface ProxyConfigurationUtils : NSObject

+ (BOOL)setProxyWithHost:(NSString*)host port:(NSUInteger)port;

+ (BOOL)disableProxy;

@end


#endif /* ProxyConfiguration_h */
