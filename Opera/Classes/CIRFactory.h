//
//  CIRFactory.h
//  Opera
//
//  Created by Pietro Caselani on 16/06/16.
//  Copyright (c) 2016 Copy Is Right. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CIRFactory <NSObject>

@required
- (BOOL)canMakeWithParameters:(NSDictionary<NSString *, id> *)params;

- (id)productWithParameters:(NSDictionary<NSString *, id> *)params;

@end

@interface CIRFactory : NSObject

+ (instancetype)shared;

- (void)registerFactoryClass:(Class)factoryClass forProductClass:(Class)productClass;

- (void)registerFactoryClass:(Class)factoryClass forProductProtocol:(Protocol *)productProtocol;

- (id)productOfClass:(Class)productClass params:(NSDictionary<NSString *, id> *)params;

- (id)productOfClass:(Class)productClass params:(NSDictionary<NSString *, id> *)params required:(BOOL)required;

- (id)productOfProtocol:(Protocol *)productProtocol params:(NSDictionary<NSString *, id> *)params;

- (id)productOfProtocol:(Protocol *)productProtocol params:(NSDictionary<NSString *, id> *)params required:(BOOL)required;

- (id <CIRFactory>)factoryForClass:(Class)productClass params:(NSDictionary<NSString *, id> *)params;

- (id <CIRFactory>)factoryForProtocol:(Protocol *)productProtocol params:(NSDictionary<NSString *, id> *)params;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToFactory:(CIRFactory *)factory;

- (NSUInteger)hash;

@end