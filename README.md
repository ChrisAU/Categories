Categories
==========

*NSArray+UpdateParser*

This class simplifies RESTful data parsing when using Core Data providing two methods that are optimised for different scenarios:
* Update - should be used only in cases where circular references exist (i.e. nested objects that refer to themselves)
* Walk - should be used in the majority of cases, it is the faster alternative

Assumptions
* Each NSManagedObject subclass should implement updateWithData:
* Each NSManagedObject subclass should have a field called 'serverID'
* Server response should include a unique field called 'id' against each object

Ideally, classes should inherit from a base class that has the 'serverID' field and any other shared fields. All subclasses of the base class should then call [super processData:] in their processData: methods.

==========

*JSON*
* These classes add methods to NSString, NSObject, and NSData types to serialise/deserialise JSON.
