Categories
==========

*Core Data -> NSManagedObjectContext+UpdateParser*

<<<<<<< HEAD:Core Data/README.md
NSArray+UpdateParser
=======
>>>>>>> 2de18e5936f5822a3f4cabe088695fd40ccea2bf:README.md
This class simplifies RESTful data parsing when using Core Data providing two methods that are optimised for different scenarios:
* Update - should be used only in cases where circular references exist (i.e. nested objects that refer to themselves)
* Walk - should be used in the majority of cases, it is the faster alternative

<<<<<<< HEAD:Core Data/README.md
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
=======
Assumptions
* Each NSManagedObject subclass should implement updateWithData:
* Each NSManagedObject subclass should have a field called 'serverID'
* Server response should include a unique field called 'id' against each object

Ideally, classes should inherit from a base class that has the 'serverID' field and any other shared fields. All subclasses of the base class should then call [super updateWithData:] in their updateWithData: methods.

==========

*JSON*
* These classes add methods to NSString, NSObject, and NSData types to serialise/deserialise JSON.
>>>>>>> 2de18e5936f5822a3f4cabe088695fd40ccea2bf:README.md
