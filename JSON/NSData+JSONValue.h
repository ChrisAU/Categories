//
//  NSData+JSONValue.h
//
//  Created by Chris Nevin on 27/10/13.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (JSONValue)

- (id)JSONValue;
- (id)JSONValueWithError:(NSError**)err;

@end
