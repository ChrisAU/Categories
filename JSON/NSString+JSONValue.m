//
//  NSString+JSONValue.m
//
//  Created by Chris Nevin on 27/10/13.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "NSString+JSONValue.h"

@implementation NSString (JSONValue)

- (id)JSONValue
{
    NSError *err = nil;
    id jsonValue = [self JSONValueWithError:&err];
    if(err) {
        DLog(@"%@", [err description]);
    }
    return jsonValue;
}

- (id)JSONValueWithError:(NSError**)err
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    id jsonValue = [NSJSONSerialization JSONObjectWithData:data
                                                   options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                     error:err];
    return jsonValue;
}

@end
