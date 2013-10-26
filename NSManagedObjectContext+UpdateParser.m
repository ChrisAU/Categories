//
//  NSManagedObjectContext+UpdateParser.m
//
//  Created by Chris Nevin on 27/10/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "NSManagedObjectContext+UpdateParser.h"

@implementation NSManagedObjectContext (UpdateParser)

- (NSArray*)itemsOfType:(NSString*)type inArray:(NSArray*)updates
{
    // Assumption: Core Data entity names match Server Updates type names
    NSArray *filtered = [updates filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary* update, NSDictionary *bindings) {
        return [type isEqualToString:update[@"type"]];
    }]];
    return filtered;
}

- (NSArray*)sortedObjectsOfType:(NSString*)entity withIdentifiers:(NSArray*)identifiers
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID IN %@", identifiers];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"serverID" ascending:YES]]];
    NSArray *objects = [self executeFetchRequest:request error:NULL];
    return objects;
}

- (NSArray*)sortedItemsInArray:(NSArray*)updates
{
    NSArray *sorted = [updates sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1[@"id"] compare:obj2[@"id"]];
    }];
    return sorted;
}

- (void)walkItemsOfType:(NSString *)entity inUpdates:(NSArray *)updates completion:(UpdateCompletionBlock)completion
{
    @autoreleasepool {
        // Collect existing objects
        if (entity) {
            NSArray *filtered = [self sortedItemsInArray:[self itemsOfType:entity inArray:updates]];
            NSMutableArray *identifiers = [NSMutableArray array], *processedIdentifiers = [NSMutableArray array];
            for (NSDictionary *update in filtered) {
                long long identifier = [update[@"id"] longLongValue];
                if (identifier > 0) {
                    [identifiers addObject:[NSNumber numberWithLongLong:identifier]];
                }
            }
            // If there are no identifiers return
            if (identifiers.count == 0) {
                if (completion) {
                    completion(nil, nil, NO);
                }
                return;
            }
            DLog(@"Walk objects for entity: %@", entity);
            // Fetch objects with matching identifiers
            NSArray *objects = [self sortedObjectsOfType:entity withIdentifiers:identifiers];
            NSInteger objectsIndex = 0;
            for (NSInteger dataIndex = 0; dataIndex < [filtered count]; dataIndex++) {
                // Get the next ID and Object.
                NSNumber *identifier = identifiers[dataIndex];
                BOOL created = NO;
                id object = nil;
                if ([objects count] > objectsIndex) {
                    object = objects[objectsIndex];
                }
                if ([identifier longLongValue] == [[object valueForKey:@"serverID"] longLongValue]) {
                    // If the IDs match, move to the next ID and Object.
                    objectsIndex++;
                }
                else {
                    // If the ID doesn't match the Object ID, create a new Object for that ID.
                    if (![processedIdentifiers containsObject:identifier]) {
                        object = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:self];
                        if ([object respondsToSelector:@selector(setServerID:)]) {
                            [object performSelector:@selector(setServerID:) withObject:identifier];
                        }
                        [processedIdentifiers addObject:identifier];
                        created = YES;
                    }
                    else{
                        object = nil;
                    }
                    
                }
                if (object) {
                    if ([object respondsToSelector:@selector(updateWithData:)]) {
                        [object performSelector:@selector(updateWithData:) withObject:filtered[dataIndex]];
                    }
                    if (completion) {
                        completion(object, filtered[dataIndex], created);
                    }
                }
            }
            processedIdentifiers = nil;
        }
    }
}

- (void)updateItemsOfType:(NSString *)entity inUpdates:(NSArray *)updates nestedTypes:(NSArray*)nestedTypes  completion:(UpdateCompletionBlock)completion
{
    @autoreleasepool {
        // Collect existing objects
        if (entity) {
            NSArray *filtered = [self itemsOfType:entity inArray:updates];
            NSMutableArray *identifiers = [NSMutableArray array];
            for (NSDictionary *update in filtered) {
                long long identifier = [update[@"id"] longLongValue];
                if (identifier > 0) {
                    [identifiers addObject:[NSNumber numberWithLongLong:identifier]];
                }
            }
            DLog(@"Update objects for entity: %@", entity);
            if (identifiers.count == 0) {
                if (completion) {
                    completion(nil, nil, NO);
                }
                return;
            }
            
            NSArray *objects = [self sortedObjectsOfType:entity withIdentifiers:identifiers];
            NSString *predicateString = [NSString stringWithFormat:@"serverID == $SERVER_ID"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
            
            // Iterate identifiers to find matching objects
            // Create any objects that don't exist
            // Parse data
            for (NSDictionary *update in filtered) {
                long long identifier = [update[@"id"] longLongValue];
                if (identifier > 0) {
                    NSNumber *identNumber = [NSNumber numberWithLongLong:identifier];
                    NSArray *matching = nil;
                    NSDictionary *variables = @{@"SERVER_ID": identNumber};
                    NSPredicate *localPredicate = [predicate predicateWithSubstitutionVariables:variables];
                    if ([nestedTypes containsObject:entity]) {
                        // Fetch on demand due to hierarchy (section references a section)
                        matching = [self fetchObjectsForEntityName:entity withPredicate:localPredicate];
                    } else {
                        // Use pre-fetched objects
                        matching = [objects filteredArrayUsingPredicate:localPredicate];
                    }
                    id object = nil;
                    BOOL created = NO;
                    if ([matching count] == 0) {
                        object = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:self];
                        if ([object respondsToSelector:@selector(setServerID:)]) {
                            [object performSelector:@selector(setServerID:) withObject:identNumber];
                        }
                        created = YES;
                    } else {
                        object = [matching lastObject];
                    }
                    if (object) {
                        if ([object respondsToSelector:@selector(updateWithData:)]) {
                            [object performSelector:@selector(updateWithData:) withObject:update];
                        }
                        if (completion) {
                            completion(object, update, created);
                        }
                    }
                }
            }
        }
    }
}

@end
