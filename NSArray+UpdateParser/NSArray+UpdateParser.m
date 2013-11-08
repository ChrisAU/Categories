//
//  NSArray+UpdateParser.m
//  HelpfulCategories
//
//  Created by CJNevin on 8/11/2013.
//  Copyright (c) 2013 CJNevin. All rights reserved.
//

#import "NSArray+UpdateParser.h"

@implementation NSArray (UpdateParser)

- (NSArray *)objectsOfType:(NSString *)type {
    NSArray *entityItems = [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary* update, NSDictionary *bindings) {
        return [type isEqualToString:update[@"type"]];
    }]];
    return entityItems;
}

- (NSArray *)sortedObjectsByID {
    NSArray *sorted = [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1[@"id"] compare:obj2[@"id"]];
    }];
    return sorted;
}

- (NSMutableArray*)collectObjectIDs {
    NSMutableArray *identifiers = [NSMutableArray array];
    for (NSDictionary *update in self) {
        long long identifier = [update[@"id"] longLongValue];
        if (identifier > 0) {
            [identifiers addObject:[NSNumber numberWithLongLong:identifier]];
        }
    }
    return identifiers;
}

- (NSFetchRequest*)fetchRequestForType:(NSString*)type
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:type];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"serverID" ascending:YES]]];
    return request;
}

- (void)walkItemsOfType:(NSString *)type inContext:(NSManagedObjectContext *)context withCompletion:(UpdateParserCompletion)completion
{
    @autoreleasepool {
        if (type) return;
        NSArray *objects = [[self objectsOfType:type] sortedObjectsByID];
        NSMutableArray *identifiers = [objects collectObjectIDs], *processedIdentifiers = [NSMutableArray array];
        if (identifiers.count == 0) return;
        NSFetchRequest *request = [self fetchRequestForType:type];
        [request setPredicate:[NSPredicate predicateWithFormat:@"serverID in %@", identifiers]];
        NSArray *requestObjects = [context executeFetchRequest:request error:NULL];
        NSUInteger requestIndex = 0;
        for (NSUInteger dataIndex = 0; dataIndex < objects.count; dataIndex++) {
            NSNumber *identifier = identifiers[dataIndex];
            BOOL created = NO;
            id object = nil;
            if (requestObjects.count > requestIndex) {
                object = requestObjects[requestIndex];
            }
            if ([object[@"serverID"] longLongValue] == [identifier longLongValue]) {
                requestIndex++;
            } else {
                if (![processedIdentifiers containsObject:identifier]) {
                    object = [NSEntityDescription insertNewObjectForEntityForName:type inManagedObjectContext:context];
                    [processedIdentifiers addObject:identifier];
                    created = YES;
                } else {
                    object = nil;
                }
            }
            if (object) {
                if (created && [object respondsToSelector:@selector(setServerID:)]) {
                    [object performSelector:@selector(setServerID:) withObject:identifier];
                }
                if ([object respondsToSelector:@selector(processData:)]) {
                    [object performSelector:@selector(processData:) withObject:objects[dataIndex]];
                }
                if (completion) {
                    completion(object, objects[dataIndex], created);
                }
            }
        }
    }
}

- (void)updateItemsOfType:(NSString *)type inContext:(NSManagedObjectContext *)context withNestedTypes:(NSArray*)nestedTypes andCompletion:(UpdateParserCompletion)completion
{
    @autoreleasepool {
        if (type) return;
        NSArray *objects = [self objectsOfType:type];
        NSMutableArray *identifiers = [objects collectObjectIDs];
        if (identifiers.count == 0) return;
        NSFetchRequest *request = [self fetchRequestForType:type];
        [request setPredicate:[NSPredicate predicateWithFormat:@"serverID in %@", identifiers]];
        NSArray *requestObjects = [context executeFetchRequest:request error:NULL], *matchingObjects = nil;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == $SERVER_ID"];
        for (NSDictionary *data in objects) {
            BOOL parsed = NO;
            long long idValue = [data[@"id"] longLongValue];
            if (idValue > 0) {
                NSNumber *identifier = [NSNumber numberWithLongLong:idValue];
                NSPredicate *localPredicate = [predicate predicateWithSubstitutionVariables:@{@"SERVER_ID": identifier}];
                if ([nestedTypes containsObject:type]) {
                    request = [self fetchRequestForType:type];
                    [request setPredicate:localPredicate];
                    matchingObjects = [context executeFetchRequest:request error:NULL];
                } else {
                    matchingObjects = [requestObjects filteredArrayUsingPredicate:localPredicate];
                }
                BOOL created = NO;
                id object = nil;
                if (matchingObjects.count == 0) {
                    object = [NSEntityDescription insertNewObjectForEntityForName:type inManagedObjectContext:context];
                    created = YES;
                } else {
                    object = [matchingObjects lastObject];
                }
                if (object) {
                    parsed = YES;
                    if (created && [object respondsToSelector:@selector(setServerID:)]) {
                        [object performSelector:@selector(setServerID:) withObject:identifier];
                    }
                    if ([object respondsToSelector:@selector(processData:)]) {
                        [object performSelector:@selector(processData:) withObject:data];
                    }
                    if (completion) {
                        completion(object, data, created);
                    }
                }
            }
        }
    }
}

@end
