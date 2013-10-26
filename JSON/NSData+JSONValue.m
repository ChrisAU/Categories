//
//  NSData+JSONValue.m
//
//  Created by Chris Nevin on 27/10/13.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "NSData+JSONValue.h"

@implementation NSData (JSONValue)

- (id)JSONValue
{
    NSError *err = nil;
    id jsonValue = [self JSONValueWithError:&err];
    if (err) {
        DLog(@"%@", [err description]);
    }
    return jsonValue;
}

- (id)JSONValueWithError:(NSError**)err
{
    id jsonValue = [NSJSONSerialization JSONObjectWithData:self
                                                   options:0
                                                     error:err];
    return jsonValue;
}

@end
