//
//  NSEnumerator+Query.m
//

#import "NSEnumerator+Query.h"


@implementation CustomEnumerator


- (id)initWithFunction:(NSEnumerator *)src nextObjectBlock:(id(^)(NSEnumerator *))nextObject
{
    self = [super init];
    if(self) {
        _src = src;
        _nextObject = [nextObject copy];
    }
    return self;
}


- (id)nextObject
{
    return _nextObject(_src);
}

@end




@implementation NSEnumerator (Query)


+(NSEnumerator *)fromNSData:(NSData*)data{
    
    NSData * _data = data;
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

+(NSEnumerator *)range:(int)start to:(int)count {
    __block int counter = start;
    return [[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        while (counter < (start + count)) {
            return [NSNumber numberWithInt:counter++];
        }
        return nil;
    }];
}


+(NSEnumerator *)repeat:(id)item count:(int)count {
    __block int counter = 0;
    return [[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        while (counter < count) {
            counter++;
            return item;
        }
        return nil;
    }];
}

+(NSEnumerator *)empty {
    return [[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        return nil;
    }];
}

- (NSEnumerator *) ofClass: (Class) classType
{
    return [[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        do {
            item = [src nextObject];
        } while (item != nil && ![item isKindOfClass:classType]);

        return item;
    }];
}


-(NSEnumerator *) select: (id(^)(id)) selector
{
    id (^_selector)(id) = [selector copy];
    return [self selectWithIndex:^id(id item, int index) {
        return _selector(item);
    }];
}


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


-(NSEnumerator *) where: (BOOL(^)(id)) predicate
{
    BOOL (^_predicate)(id) = [predicate copy];
    return [self whereWithIndex:^BOOL(id item, int index) {
        return _predicate(item);
    }];
}


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


-(NSEnumerator *) skip: (int)count
{
    __block int counter = 0;
    return [[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        while (counter++ < count)
        {
            if(!(item = [src nextObject]))
                return nil;
        }
        return [src nextObject];
    }];
}


-(NSEnumerator *) skipWhile: (BOOL(^)(id item)) predicate
{
    return [self skipWhileWithIndex:^BOOL(id item, int index) {
        return predicate(item);
    }];
}


-(NSEnumerator *) skipWhileWithIndex: (BOOL(^)(id,int)) predicate
{
    __block int counter = 0;
    __block BOOL skipped = NO;
    BOOL (^_predicate)(id,int) = [predicate copy];
    return [[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        if (!skipped)
        {
            do {
                if(!(item = [src nextObject]))
                    return nil;
            } while (_predicate(item,counter++));
            skipped = YES;
            return item;
        }
        return [src nextObject];
    }];
}


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


-(NSEnumerator *) takeWhile: (BOOL(^)(id item)) predicate
{
    return [self takeWhileWithIndex:^BOOL(id item, int index) {
        return predicate(item);
    }];
}


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
    return [[result sortedArrayUsingDescriptors:array]objectEnumerator];
}


- (NSEnumerator *) selectMany: (id(^)(id)) selector
{
    id (^_selector)(id) = [selector copy];
    __block id current = [self nextObject];
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

- (NSEnumerator *) distinct{
    
    __block NSMutableArray *returnedArray = [[NSMutableArray alloc]init];
    return [[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        while((item = [src nextObject]) != nil && [returnedArray containsObject:item]){
            NSLog(@"skip : %@",item);
        }
        if(item)
        {
            NSLog(@"return %@",item);
            [returnedArray addObject:item];
            return item;
        }
        return item;
    }];
}

- (NSEnumerator *) concat:(NSEnumerator *)dst
{
    NSEnumerator *_dst = dst;
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


- (NSEnumerator *) union:(NSEnumerator *)dst{
    return [[self concat:dst]distinct];
}

- (NSEnumerator *) intersect:(NSEnumerator *)dst{
    NSArray *dstArray = [dst toArray];
    return [self where:^BOOL(id item) {
        return [dstArray containsObject:item];
    }];
}

- (NSEnumerator *) except:(NSEnumerator *)dst{
    NSArray *dstArray = [dst toArray];
    return [self where:^BOOL(id item) {
        return ![dstArray containsObject:item];
    }];
}

- (NSEnumerator *) buffer:(int)count;
{
    return [[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        NSArray *result = [[src take:count]toArray];
        return (result.count == 0) ? nil: result;
    }];
}

- (NSArray*) toArray
{
    return [self allObjects];
}

- (NSMutableArray*) toMutableArray
{
    NSMutableArray *result = [[NSMutableArray alloc]init];
    for (id value in self) {
        [result addObject:value];
    }
    return result;
}

- (NSDictionary *) toDictionary: (id(^)(id)) keySelector{
    NSArray* keyArray = [[(NSEnumerator*)[self copy]select:^id(id item) {
        return keySelector(item);
    }]toArray];
    return [[NSDictionary alloc]initWithObjects:[self toArray] forKeys:keyArray];
}

- (NSDictionary *) toDictionary: (id(^)(id)) keySelector elementSelector:(id(^)(id)) elementSelector{
    NSArray* keyArray = [[(NSEnumerator*)[self copy]select:^id(id item) {
        return keySelector(item);
    }]toArray];
    NSArray* elementArray = [[self select:^id(id item) {
        return elementSelector(item);
    }]toArray];
    return [[NSDictionary alloc]initWithObjects:elementArray forKeys:keyArray];
}

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


-(id) elementOrNilAt:(int)index
{
    return [[self toArray]objectAtIndex:index];
}

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

-(id) single:(BOOL(^)(id)) predicate
{
    return [[self where:predicate]single];
}

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
-(id) singleOrNil:(BOOL(^)(id)) predicate
{
    return [[self where:predicate]singleOrNil];
}

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

-(id) first:(BOOL(^)(id)) predicate
{
    return [[self where:predicate]first];
}


-(id) firstOrNil
{
    return [self nextObject];
}

-(id) firstOrNil:(BOOL(^)(id)) predicate
{
    return [[self where:predicate]firstOrNil];
}


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

-(id) last:(BOOL(^)(id)) predicate
{
    return [[self where:predicate]last];
}


-(id) lastOrNil
{
    return [[self toArray]lastObject];
}

-(id) lastOrNil:(BOOL(^)(id)) predicate
{
    return [[self where:predicate]lastOrNil];
}


-(int) count
{
    return [self toArray].count;
}


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


-(BOOL) sequenceEqual: (NSEnumerator *)dst
{
    NSArray *srcArray = [self toArray];
    NSArray *dstArray = [dst toArray];
    return [srcArray isEqualToArray:dstArray];
}


- (void) forEach: (void(^)(id)) action
{
    for (id value in self) {
        action(value);
    }
}

@end