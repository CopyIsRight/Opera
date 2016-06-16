//
//  CIRFactory.m
//  Pods
//
//  Created by Pietro Caselani on 16/06/16.
//  Copyright (c) 2016 Copy Is Right. All rights reserved.
//

#import "CIRFactory.h"

@interface CIRFactory ()

@property(nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *factoriesDictionary;

@end

@implementation CIRFactory

//region Initialization
- (instancetype)init
{
	if (self = [super init])
	{
		_factoriesDictionary = [[NSMutableDictionary alloc] init];
	}

	return self;
}

+ (instancetype)shared
{
	static CIRFactory *instance = nil;

	if (instance == nil)
		instance = [[CIRFactory alloc] init];

	return instance;
}
//endregion

//region Equality
- (BOOL)isEqual:(id)other
{
	if (other == self)
		return YES;
	if (!other || ![[other class] isEqual:[self class]])
		return NO;

	return [self isEqualToFactory:other];
}

- (BOOL)isEqualToFactory:(CIRFactory *)factory
{
	if (self == factory)
		return YES;
	if (factory == nil)
		return NO;
	return !(self.factoriesDictionary != factory.factoriesDictionary && ![self.factoriesDictionary isEqualToDictionary:factory.factoriesDictionary]);
}

- (NSUInteger)hash
{
	return [self.factoriesDictionary hash] * 11u;
}
//endregion

//region Public
- (void)registerFactoryClass:(Class)factoryClass forProductClass:(Class)productClass
{
	NSString *key = NSStringFromClass(productClass);
	NSString *factoryClassName = NSStringFromClass(factoryClass);

	NSMutableArray<NSString *> *factories = _factoriesDictionary[key];
	if (factories == nil)
	{
		factories = [[NSMutableArray alloc] init];
		_factoriesDictionary[key] = factories;
	}

	[factories addObject:factoryClassName];
}

- (id)productOfClass:(Class)productClass params:(NSDictionary<NSString *, id> *)params
{
	return [self productOfClass:productClass params:params required:YES];
}

- (id)productOfClass:(Class)productClass params:(NSDictionary<NSString *, id> *)params required:(BOOL)required
{
	id <CIRFactory> factory = [self factoryForClass:productClass params:params];

	if (factory == nil && required)
	{
		NSString *reason = [NSString stringWithFormat:@"No registered factory for product of type `%@` with parameters %@.", NSStringFromClass(productClass), params];
		@throw [NSException exceptionWithName:@"NoFactoryFoundException" reason:reason userInfo:nil];
	}

	return [factory productWithParameters:params];
}

- (id <CIRFactory>)factoryForClass:(Class)productClass params:(NSDictionary<NSString *, id> *)params
{
	NSString *key = NSStringFromClass(productClass);
	NSMutableArray<NSString *> *factories = _factoriesDictionary[key];

	id <CIRFactory> selected = nil, factory;

	for (NSString *factoryName in factories)
	{
		Class factoryClass = NSClassFromString(factoryName);
		factory = [[factoryClass alloc] init];
		if ([factory canMakeWithParameters:params])
		{
			if (selected)
			{
				NSString *reason = [NSString stringWithFormat:@"Found multiple factories for product of type `%@` with parameters: %@", key, params];
				@throw [NSException exceptionWithName:@"MultipleFactoriesFoundException" reason:reason userInfo:nil];
			}
			else
				selected = factory;
		}
	}

	return selected;
}
//endregion

@end