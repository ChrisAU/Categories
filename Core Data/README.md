Categories
==========

Useful categories

NSArray+UpdateParser
This class simplifies RESTful data parsing when using Core Data providing two methods that are optimised for different scenarios:

// Walk should be used in the majority of cases, it is the faster alternative
- (void)walkItemsOfType:(NSString*)type inContext:(NSManagedObjectContext*)context withCompletion:(UpdateParserCompletion)completion;

// Update should be used only in cases where circular references exist
// i.e.: nested objects that refer to themselves
- (void)updateItemsOfType:(NSString*)type inContext:(NSManagedObjectContext*)context withNestedTypes:(NSArray*)nestedTypes andCompletion:(UpdateParserCompletion)completion;

Assumptions:
* Each NSManagedObject subclass implements - (void)processData:(NSDictionary*)data
* Each NSManagedObject subclass has a field called 'serverID'
* Server response includes a unique field called 'id' against each object

Ideally, classes should inherit from a base class that has the 'serverID' field and any other shared fields. All subclasses of the base class should then call [super processData:] in their processData: methods.
