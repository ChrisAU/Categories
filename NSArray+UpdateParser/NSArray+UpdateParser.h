//
//  NSArray+UpdateParser.h
//  HelpfulCategories
//
//  Created by CJNevin on 8/11/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^UpdateParserCompletion)(NSManagedObject *object, NSDictionary *update, BOOL created);

@interface NSArray (UpdateParser)

// Walk should be used in the majority of cases, it is the faster alternative
- (void)walkItemsOfType:(NSString*)type inContext:(NSManagedObjectContext*)context withCompletion:(UpdateParserCompletion)completion;
// Update should be used only in cases where circular references exist
- (void)updateItemsOfType:(NSString*)type inContext:(NSManagedObjectContext*)context withNestedTypes:(NSArray*)nestedTypes andCompletion:(UpdateParserCompletion)completion;

@end
