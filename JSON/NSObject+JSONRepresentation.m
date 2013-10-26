//
//  NSObject+JSONRepresentation.m
//
//  Created by Chris Nevin on 27/10/13.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "NSObject+JSONRepresentation.h"

@implementation NSObject (JSONRepresentation)

-(NSString*) jsonWithOption:(int) option
{
    NSError *err = nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                   options:option
                                                     error:&err];
    
    if(err)
        NSLog(@"%@", [err description]);
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}

- (NSString *)prettyJSON {
    
    return [self jsonWithOption:NSJSONWritingPrettyPrinted];
}

- (NSString *)JSONRepresentation {
    
    return [self jsonWithOption:0];
}

@end
