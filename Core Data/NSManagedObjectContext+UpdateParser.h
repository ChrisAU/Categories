//
//  NSManagedObjectContext+UpdateParser.h
//
//  Created by Chris Nevin on 27/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef void (^UpdateCompletionBlock)(NSManagedObject *obj, NSDictionary *update, BOOL created);

@interface NSManagedObjectContext (UpdateParser)

// Walk should be used in the majority of cases, it is the faster alternative
- (void)walkItemsOfType:(NSString*)entity inUpdates:(NSArray*)updates completion:(UpdateCompletionBlock)completion;

// Update should be used only in cases where circular references exist
// i.e.: nested objects that refer to themselves
- (void)updateItemsOfType:(NSString *)entity inUpdates:(NSArray *)updates nestedTypes:(NSArray*)nestedTypes completion:(UpdateCompletionBlock)completion;

@end
