//
//  NSEnumerator+Additions.m
//  TesApp
//
//  Created by 鮫島 隆治 on 2012/10/27.
//  Copyright (c) 2012年 鮫島 隆治. All rights reserved.
//

#import "NSEnumerator+Query.h"

/**************************************************************************/
/// @name
@implementation CustomEnumerator

/**************************************************************************/
/// @name
- (id)initWithFunction:(NSEnumerator *)src nextObjectBlock:(id(^)(NSEnumerator *))nextObject
{
    self = [super init];
    if(self) {
        _src = src;
        _nextObject = [nextObject copy];
    }
    return self;
}

/**************************************************************************/
/// @name
- (id)nextObject
{
    return _nextObject(_src);
}

@end



/**************************************************************************/
/// @name
@implementation NSEnumerator (Query)

/**************************************************************************/
/// @name
+(NSEnumerator *)fromNSData:(NSData*)data{
    
    __block NSData * _data = data;
    __block int counter = 0;
    
    
    return [[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
            while (counter < [_data length]) {
                
                const void* chardata= [_data bytes] + counter;
                
                NSNumber * result = [NSNumber numberWithChar:(*((char *)chardata))];
                counter++;
                return result;
            }
            return nil;
        }];
}

/**************************************************************************/
/// @name
- (NSEnumerator *) ofClass: (Class) class
{
    return [[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        do {
            item = [src nextObject];
        } while (item != nil && ![item isKindOfClass:class]);

        return item;
    }];
}

/**************************************************************************/
/// @name
-(NSEnumerator *) select: (id(^)(id)) selector
{
    id (^_selector)(id) = [selector copy];
    return [self selectWithIndex:^id(id item, int index) {
        return _selector(item);
    }];
}

/**************************************************************************/
/// @name
-(NSEnumerator *) selectWithIndex: (id(^)(id,int)) selector
{
    __block int counter = 0;
    id (^_selector)(id,int) = [selector copy];
    return [[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        while ((item = [src nextObject]))
        {
            return _selector(item,counter++);
        }
        return nil;
    }];
}

/**************************************************************************/
/// @name
-(NSEnumerator *) where: (BOOL(^)(id)) predicate
{
    BOOL (^_predicate)(id) = [predicate copy];
    return [self whereWithIndex:^BOOL(id item, int index) {
        return _predicate(item);
    }];
}

/**************************************************************************/
/// @name
-(NSEnumerator *) whereWithIndex: (BOOL(^)(id,int)) predicate
{
    __block int counter = 0;
    BOOL (^_predicate)(id,int) = [predicate copy];
    return [[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        while ((item = [src nextObject]))
        {
            if(_predicate(item,counter++))
            return item;
        }
        return nil;
    }];
}

/**************************************************************************/
/// @name
-(NSEnumerator *) skip: (int)count
{
    __block int counter = 0;
    return [[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        while (counter++ < count && (item = [src nextObject]));
        return item;
        return nil;
    }];
}

/**************************************************************************/
/// @name
-(NSEnumerator *) skipWhile: (BOOL(^)(id item)) predicate
{
    return [self skipWhileWithIndex:^BOOL(id item, int index) {
        return predicate(item);
    }];
}

/**************************************************************************/
/// @name
-(NSEnumerator *) skipWhileWithIndex: (BOOL(^)(id,int)) predicate
{
    __block int counter = 0;
    __block BOOL skipped = false;
    BOOL (^_predicate)(id,int) = [predicate copy];
    return [[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        if (!skipped)
        {
            while ((item = [src nextObject]) && _predicate(item,counter++));
            return item;
        }
        return [src nextObject];
    }];
}

/**************************************************************************/
/// @name
-(NSEnumerator *) take: (int)count
{
    __block int counter = 0;
    return [[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        if (counter++ < count && (item = [src nextObject]))
        {
            return item;
        }
        return nil;
    }];
}

/**************************************************************************/
/// @name
-(NSEnumerator *) takeWhile: (BOOL(^)(id item)) predicate
{
    return [self takeWhileWithIndex:^BOOL(id item, int index) {
        return predicate(item);
    }];
}

/**************************************************************************/
/// @name
-(NSEnumerator *) takeWhileWithIndex: (BOOL(^)(id,int)) predicate
{
    __block int counter = 0;
    __block BOOL taking = true;
    BOOL (^_predicate)(id,int) = [predicate copy];
    return [[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        if (taking && (item = [src nextObject]))
        {
            while ((taking = _predicate(item,counter++)))
            {
                return item;
            }
        }
        return nil;
    }];
}

/**************************************************************************/
/// @name
-(NSEnumerator *)orderByDescription:(NSSortDescriptor *)firstObj, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list list;
    va_start(list, firstObj);
    NSMutableArray *array = [[NSMutableArray alloc]initWithObjects:firstObj, nil];
    NSSortDescriptor *desc;
    while((desc = va_arg(list, NSSortDescriptor*)))
    {
        [array addObject:desc];
    }
    va_end(list);
    NSArray *result = [self toArray];
    [result sortedArrayUsingDescriptors:array];
    return [result objectEnumerator];
}

/**************************************************************************/
/// @name
- (NSEnumerator *) selectMany: (id(^)(id)) selector
{
    id (^_selector)(id) = [selector copy];
    __block NSEnumerator *current = [self nextObject];
    return [[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        while ((item = [current nextObject]))
        {
            return _selector(item);
        }
        if((current = [self nextObject]))
        {
            return [current nextObject];
        }
        return nil;
    }];
}

/**************************************************************************/
/// @name
- (NSEnumerator *) concat:(NSEnumerator *)dst
{
    __weak NSEnumerator *_dst = dst;
    __block BOOL isFirst = true;
    return [[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        if (isFirst)
        {
            if((item = [self nextObject]))
            {
                return item;
            }
            else
            {
                isFirst = false;
                return [_dst nextObject];
            }
        }
        else
        {
            return [_dst nextObject];
        }
    }];
}

/**************************************************************************/
/// @name
- (NSMutableArray*) toArray
{
    NSMutableArray *result = [[NSMutableArray alloc]init];
    for (id value in self) {
        [result addObject:value];
    }
    return result;
}

/**************************************************************************/
/// @name
-(NSData *) toNSData
{
    NSArray * array = [self allObjects];
    NSMutableData *result = [[NSMutableData alloc]initWithCapacity:[array count]];
    for (NSNumber * obj in array) {
        char charByte = [obj charValue];
        [result appendBytes:&charByte length:1];
    }
    return result;
}


/**************************************************************************/
/// @name
-(id) single
{
    id item = [self nextObject];
    if(item && [self nextObject] == nil)
        return item;
    else
        [[NSException exceptionWithName:NSInvalidArgumentException
                                 reason:@"Result returned -1.."
                               userInfo:nil]
         raise];
    return nil;
}

/**************************************************************************/
/// @name
-(id) singleOrNil
{
    id item = [self nextObject];
    if([self nextObject] == nil)
        return item;
    else
        [[NSException exceptionWithName:NSInvalidArgumentException
                                 reason:@"Result returned -1.."
                               userInfo:nil]
         raise];
    return nil;
}

/**************************************************************************/
/// @name
-(id) elementAt:(int)index
{
    id item = [[self toArray]objectAtIndex:index];
    if(item)
        return item;
    else
        [[NSException exceptionWithName:NSInvalidArgumentException
                                 reason:@"Result returned -1.."
                               userInfo:nil]
         raise];
    return nil;
}

/**************************************************************************/
/// @name
-(id) elementOrNilAt:(int)index
{
    return [[self toArray]objectAtIndex:index];
}

/**************************************************************************/
/// @name
-(id) first
{
    id item = [self nextObject];
    if(item)
        return item;
    else
        [[NSException exceptionWithName:NSInvalidArgumentException
                                 reason:@"Result returned -1.."
                               userInfo:nil]
         raise];
    return nil;
}

/**************************************************************************/
/// @name
-(id) firstOrNil
{
    return [self nextObject];
}

/**************************************************************************/
/// @name
-(id) last
{
    id item = [[self toArray]lastObject];
    if(item)
        return item;
    else
        [[NSException exceptionWithName:NSInvalidArgumentException
                                 reason:@"Result returned -1.."
                               userInfo:nil]
         raise];
    return nil;
}

/**************************************************************************/
/// @name
-(id) lastOrNil
{
    return [[self toArray]lastObject];
}

/**************************************************************************/
/// @name
-(int) count
{
    return [self toArray].count;
}

/**************************************************************************/
/// @name
-(BOOL) all: (BOOL(^)(id)) predicate
{
    id item;
    while ((item = [self nextObject]))
    {
        if(!predicate(item))
            return NO;
    }
    return YES;
}

/**************************************************************************/
/// @name
-(BOOL) any: (BOOL(^)(id)) predicate
{
    id item;
    while ((item = [self nextObject]))
    {
        if(predicate(item))
            return YES;
    }
    return NO;
}

/**************************************************************************/
/// @name
-(BOOL) contains : (id) item
{
    id dst;
    while ((dst = [self nextObject]))
    {
        if([dst isEqual:(item)])
            return YES;
    }
    return NO;
}

/**************************************************************************/
/// @name
-(BOOL) sequenceEqual: (NSEnumerator *)dst
{
    id srcItem;
    id dstItem;
    while ((srcItem = [self nextObject]))
    {
        if(!(dstItem = [dst nextObject]))
            return NO;
        
        if(![srcItem isEqual:dstItem])
            return NO;
    }
    if((dstItem = [self nextObject]))
        return NO;
    return YES;
}

/**************************************************************************/
/// @name
- (void) forEach: (void(^)(id)) action
{
    for (id value in self) {
        action(value);
    }
}

@end