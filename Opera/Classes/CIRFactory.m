//
//  CIRFactory.m
//  Pods
//
//  Created by Pietro Caselani on 16/06/16.
//  Copyright (c) 2016 Copy Is Right. All rights reserved.
//

#import "CIRFactory.h"

@interface CIRFactory ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *factoriesDictionary;

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

//region Registration

- (void)registerFactoryClass:(Class)factoryClass forProductClass:(Class)productClass
{
	[self registerFactoryClass:factoryClass forProductName:NSStringFromClass(productClass)];
}

- (void)registerFactoryClass:(Class)factoryClass forProductProtocol:(Protocol *)productProtocol
{
	[self registerFactoryClass:factoryClass forProductName:NSStringFromProtocol(productProtocol)];
}

//endregion

//region Creation

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

- (id)productOfProtocol:(Protocol *)productProtocol params:(NSDictionary<NSString *, id> *)params
{
	return [self productOfProtocol:productProtocol params:params required:YES];
}

- (id)productOfProtocol:(Protocol *)productProtocol params:(NSDictionary<NSString *, id> *)params required:(BOOL)required
{
	id <CIRFactory> factory = [self factoryForProtocol:productProtocol params:params];

	if (factory == nil && required)
	{
		NSString *reason = [NSString stringWithFormat:@"No registered factory for product of type `%@` with parameters %@.", NSStringFromProtocol(productProtocol), params];
		@throw [NSException exceptionWithName:@"NoFactoryFoundException" reason:reason userInfo:nil];
	}

	return [factory productWithParameters:params];
}

//endregion

//region Factory finder

- (id <CIRFactory>)factoryForClass:(Class)productClass params:(NSDictionary<NSString *, id> *)params
{
	return [self factoryWithName:NSStringFromClass(productClass) params:params];
}

- (id <CIRFactory>)factoryForProtocol:(Protocol *)productProtocol params:(NSDictionary<NSString *, id> *)params
{
	return [self factoryWithName:NSStringFromProtocol(productProtocol) params:params];
}

//endregion

//region Private

- (void)registerFactoryClass:(Class)factoryClass forProductName:(NSString *)productName
{
	NSString *factoryClassName = NSStringFromClass(factoryClass);

	NSMutableArray<NSString *> *factories = _factoriesDictionary[productName];
	if (factories == nil)
	{
		factories = [[NSMutableArray alloc] init];
		_factoriesDictionary[productName] = factories;
	}

	[factories addObject:factoryClassName];
}

- (id <CIRFactory>)factoryWithName:(NSString *)name params:(NSDictionary<NSString *, id> *)params
{
	NSMutableArray<NSString *> *factories = _factoriesDictionary[name];

	id <CIRFactory> selected = nil, factory;

	for (NSString *factoryName in factories)
	{
		Class factoryClass = NSClassFromString(factoryName);
		factory = [[factoryClass alloc] init];
		if ([factory canMakeWithParameters:params])
		{
			if (selected)
			{
				NSString *reason = [NSString stringWithFormat:@"Found multiple factories for product of type `%@` with parameters: %@", name, params];
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