//
//  NSObject+JSONRepresentation.h
//
//  Created by Chris Nevin on 27/10/13.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JSONRepresentation)

- (NSString *)prettyJSON;
- (NSString *)JSONRepresentation;

@end
