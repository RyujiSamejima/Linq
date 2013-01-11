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
        _nextObject = [[nextObject copy]autorelease];
    }
    return self;
}


- (id)nextObject
{
    return _nextObject(_src);
}

@end

//メソッドチェインバージョン
#ifdef USE_METHOD_CHAIN

@implementation NSData (Query)

@dynamic getEnumerator;
-(NSEnumerator *(^)())getEnumerator
{
    __unsafe_unretained NSData *weakSelf = self;
    return [[^() {
        __block int counter = 0;
        return [[[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
            while (counter < [weakSelf length]) {
                
                return [NSNumber numberWithChar:(*((char *)([weakSelf bytes] + counter++)))];
            }
            return nil;
        }]autorelease];
    }copy]autorelease];
}

@end

@implementation NSString (Query)

@dynamic getEnumerator;
-(NSEnumerator *(^)())getEnumerator
{
    __unsafe_unretained NSString *weakSelf = self;
    return [[^() {
        __block int counter = 0;
        
        return [[[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
            while (counter < [weakSelf length]) {
                return [NSNumber numberWithUnsignedShort:[weakSelf characterAtIndex:counter++]];
            }
            return nil;
        }]autorelease];
    }copy]autorelease];
}

@end

@implementation NSArray (Query)

@dynamic getEnumerator;
-(NSEnumerator *(^)())getEnumerator
{
    __unsafe_unretained NSArray *weakSelf = self;
    return [[^() {
        return [weakSelf objectEnumerator];
    }copy]autorelease];
}

@end

@implementation NSDictionary (Query)

@dynamic getEnumerator;
-(NSEnumerator *(^)())getEnumerator
{
    __unsafe_unretained NSDictionary *weakSelf = self;
    return [[^() {
        return [weakSelf objectEnumerator];
    }copy]autorelease];
}

@dynamic getKeyEnumerator;
-(NSEnumerator *(^)())getKeyEnumerator
{
    __unsafe_unretained NSDictionary *weakSelf = self;
    return [[^() {
        return [weakSelf keyEnumerator];
    }copy]autorelease];
}

@end


@implementation NSEnumerator (Query)

+(NSEnumerator *)range:(int)start to:(int)count {
    __block int counter = start;
    return [[[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        while (counter < (start + count)) {
            return [NSNumber numberWithInt:counter++];
        }
        return nil;
    }]autorelease];
}


+(NSEnumerator *)repeat:(id)item count:(int)count {
    __block int counter = 0;
    return [[[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        while (counter < count) {
            counter++;
            return item;
        }
        return nil;
    }] autorelease];
}

+(NSEnumerator *)empty {
    return [[[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        return nil;
    }]autorelease];
}

@dynamic ofClass;
- (NSEnumerator *(^)(Class))ofClass
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^NSEnumerator *(Class classType) {
        return [[[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
            id item;
            do {
                item = [src nextObject];
            } while (item != nil && ![item isKindOfClass:classType]);
            
            return item;
        }]autorelease];
    }copy]autorelease];
}

@dynamic select;
-(NSEnumerator *(^)(id(^)(id)))select
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(id (^selector)(id)) {
        id (^_selector)(id) = [[selector copy]autorelease];
        return weakSelf.selectWithIndex(^id(id item, int index) {
            return _selector(item);
        });
    }copy]autorelease];
}

@dynamic selectWithIndex;
-(NSEnumerator *(^)(id(^)(id,int)))selectWithIndex
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(id(^selector)(id,int)) {
        __block int counter = 0;
        id (^_selector)(id,int) = [[selector copy]autorelease];
        return [[[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
            id item;
            while ((item = [src nextObject]))
            {
                return _selector(item,counter++);
            }
            return nil;
        }]autorelease];
    }copy]autorelease];
}

@dynamic where;
-(NSEnumerator *(^)(BOOL(^)(id)))where
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = [[predicate copy]autorelease];
        return weakSelf.whereWithIndex(^BOOL(id item, int index) {
            return _predicate(item);
        });
    }copy]autorelease];
}

@dynamic whereWithIndex;
-(NSEnumerator *(^)(BOOL(^)(id,int)))whereWithIndex
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(BOOL(^predicate)(id,int)) {
        __block int counter = 0;
        BOOL (^_predicate)(id,int) = [[predicate copy]autorelease];
        return [[[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
            id item;
            while ((item = [src nextObject]))
            {
                if(_predicate(item,counter++))
                return item;
            }
            return nil;
        }]autorelease];
    }copy]autorelease];
}

@dynamic skip;
-(NSEnumerator *(^)(int))skip
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(int count) {
        __block int counter = 0;
        return [[[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
            id item;
            while (counter++ < count)
            {
                if(!(item = [src nextObject]))
                    return nil;
            }
            return [src nextObject];
        }]autorelease];
    }copy]autorelease];
}

@dynamic skipWhile;
-(NSEnumerator *(^)(BOOL(^)(id)))skipWhile
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = [[predicate copy]autorelease];
        return weakSelf.skipWhileWithIndex(^BOOL(id item, int index) {
            return _predicate(item);
        });
    }copy]autorelease];
    
}

@dynamic skipWhileWithIndex;
-(NSEnumerator *(^)(BOOL(^)(id,int)))skipWhileWithIndex
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(BOOL(^predicate)(id,int)) {
        __block int counter = 0;
        __block BOOL skipped = NO;
        BOOL (^_predicate)(id,int) = [[predicate copy]autorelease];
        return [[[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
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
        }]autorelease];
    }copy]autorelease];
}

@dynamic take;
-(NSEnumerator *(^)(int))take
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(int count) {
        __block int counter = 0;
        return [[[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
            id item;
            if (counter++ < count && (item = [src nextObject]))
            {
                return item;
            }
            return nil;
        }]autorelease];
    }copy]autorelease];
}

@dynamic takeWhile;
-(NSEnumerator *(^)(BOOL(^)(id)))takeWhile
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(BOOL(^predicate)(id)) {
        return weakSelf.takeWhileWithIndex(^BOOL(id item, int index) {
            return predicate(item);
        });
    }copy]autorelease];
}

@dynamic takeWhileWithIndex;
-(NSEnumerator *(^)(BOOL(^)(id,int)))takeWhileWithIndex
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(BOOL(^predicate)(id,int)) {
        __block int counter = 0;
        __block BOOL taking = YES;
        BOOL (^_predicate)(id,int) = [[predicate copy]autorelease];
        return [[[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
            id item;
            if (taking && (item = [src nextObject]))
            {
                while ((taking = _predicate(item,counter++)))
                {
                    return item;
                }
            }
            return nil;
        }]autorelease];
    }copy]autorelease];
}

@dynamic scan;
-(NSEnumerator *(^)(id(^)(id,id)))scan
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(id(^accumlator)(id, id)) {
        id (^_accumlator)(id,id) = [[accumlator copy]autorelease];
        __block BOOL first = YES;
        __block id result;
        return [[[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
            id item;
            while ((item = [src nextObject]))
            {
                if (first) {
                    result = item;
                    first = NO;
                } else {
                    result = _accumlator(result, item);
                }
                return result;
            }
            return nil;
        }]autorelease];
    }copy]autorelease];
}

@dynamic orderByDescription;
-(NSEnumerator *(^)(NSSortDescriptor *, ...))orderByDescription
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(NSSortDescriptor *firstObj, ...) {
        va_list list;
        va_start(list, firstObj);
        NSMutableArray *array = [[[NSMutableArray alloc]initWithObjects:firstObj, nil] autorelease];
        NSSortDescriptor *desc;
        while((desc = va_arg(list, NSSortDescriptor*)))
        {
            [array addObject:desc];
        }
        va_end(list);
        NSArray *result = weakSelf.toArray();
        return [result sortedArrayUsingDescriptors:array].getEnumerator();
    }copy]autorelease];
}

@dynamic selectMany;
- (NSEnumerator *(^)(id(^)(id)))selectMany
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(id(^selector)(id)) {
        id (^_selector)(id) = [[selector copy]autorelease];
        __block id current = [self nextObject];
        return [[[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
            id item;
            while ((item = [current nextObject]))
            {
                return _selector(item);
            }
            if((current = [src nextObject]))
            {
                return [current nextObject];
            }
            return nil;
        }]autorelease];
    }copy]autorelease];
}

@dynamic distinct;
- (NSEnumerator *(^)())distinct
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^() {
        __block NSMutableArray *returnedArray = [[NSMutableArray alloc]init];
        return [[[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
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
        }]autorelease];
    }copy]autorelease];
}

@dynamic concat;
- (NSEnumerator *(^)(NSEnumerator *))concat
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(NSEnumerator *dst) {
        __block BOOL isFirst = true;
        return [[[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
            id item;
            if (isFirst)
            {
                if((item = [src nextObject]))
                {
                    return item;
                }
                else
                {
                    isFirst = false;
                    return [dst nextObject];
                }
            }
            else
            {
                return [dst nextObject];
            }
        }]autorelease];
    }copy]autorelease];
}

@dynamic unions;
- (NSEnumerator *(^)(NSEnumerator *))unions
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(NSEnumerator *dst) {
        return weakSelf.concat(dst).distinct();
    }copy]autorelease];
}

@dynamic intersect;
- (NSEnumerator *(^)(NSEnumerator *))intersect
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(NSEnumerator *dst) {
        NSArray *dstArray = dst.toArray();
        return weakSelf.where(^BOOL(id item) {
            return [dstArray containsObject:item];
        });
    }copy]autorelease];
}

@dynamic except;
- (NSEnumerator *(^)(NSEnumerator *))except
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(NSEnumerator *dst) {
        NSArray *dstArray = dst.toArray();
        return weakSelf.where(^BOOL(id item) {
            return ![dstArray containsObject:item];
        });
    }copy]autorelease];
}

@dynamic buffer;
- (NSEnumerator *(^)(int))buffer;
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(int count) {
        return [[[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
            NSArray *result = src.take(count).toArray();
            return (result.count == 0) ? nil: result;
        }]autorelease];
    }copy]autorelease];
}

@dynamic toArray;
- (NSArray*(^)())toArray
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^() {
        return [weakSelf allObjects];
    }copy]autorelease];
}

@dynamic toMutableArray;
- (NSMutableArray*(^)())toMutableArray
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^() {
        NSMutableArray *result = [[[NSMutableArray alloc]init]autorelease];
        for (id value in weakSelf) {
            [result addObject:value];
        }
        return result;
    }copy]autorelease];
}

@dynamic toDictionary;
- (NSDictionary *(^)(id(^)(id)))toDictionary
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(id(^keySelector)(id)) {
        NSArray* objArray = weakSelf.toArray();
        NSArray* keyArray = objArray.getEnumerator()
        .select(^id(id item) { return keySelector(item); })
        .toArray();
        return [[[NSDictionary alloc]initWithObjects:objArray forKeys:keyArray]autorelease];
    }copy]autorelease];
}

@dynamic toDictionaryWithSelector;
- (NSDictionary *(^)(id(^)(id), id(^)(id)))toDictionaryWithSelector
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(id(^keySelector)(id), id(^elementSelector)(id)) {
        NSArray* objArray = weakSelf.toArray();
        NSArray* keyArray = objArray.getEnumerator()
        .select(^id(id item) { return keySelector(item); })
        .toArray();
        NSArray* elementArray = objArray.getEnumerator()
        .select(^id(id item) { return elementSelector(item); })
        .toArray();
        return [[[NSDictionary alloc]initWithObjects:elementArray forKeys:keyArray]autorelease];
    }copy]autorelease];
}

@dynamic toMutableDictionary;
- (NSMutableDictionary *(^)(id(^)(id)))toMutableDictionary
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(id(^keySelector)(id)) {
        NSArray* objArray = weakSelf.toArray();
        NSArray* keyArray = objArray.getEnumerator()
        .select(^id(id item) { return keySelector(item); })
        .toArray();
        return [[[NSMutableDictionary alloc]initWithObjects:objArray forKeys:keyArray]autorelease];
    }copy]autorelease];
}

@dynamic toMutableDictionaryWithSelector;
- (NSMutableDictionary *(^)(id(^)(id), id(^)(id)))toMutableDictionaryWithSelector
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(id(^keySelector)(id), id(^elementSelector)(id)) {
        NSArray* objArray = weakSelf.toArray();
        NSArray* keyArray = objArray.getEnumerator()
        .select(^id(id item) { return keySelector(item);})
        .toArray();
        NSArray* elementArray = objArray.getEnumerator()
        .select(^id(id item) { return elementSelector(item); })
        .toArray();
        return [[[NSMutableDictionary alloc]initWithObjects:elementArray forKeys:keyArray] autorelease];
    }copy]autorelease];
}

@dynamic toData;
-(NSData *(^)())toData
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^() {
        NSArray * array = [weakSelf allObjects];
        NSMutableData *result = [[[NSMutableData alloc]initWithCapacity:[array count]] autorelease];
        for (NSNumber * obj in array) {
            char charByte = [obj charValue];
            [result appendBytes:&charByte length:1];
        }
        return result;
    }copy]autorelease];
}

@dynamic toString;
-(NSString *(^)())toString
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^() {
        __block NSString *str = [[[NSString alloc]init]autorelease];
        weakSelf.forEach(^(id number) {
            unichar charShort = [(NSNumber*)number unsignedShortValue];
            [str stringByAppendingString:[NSString stringWithCharacters:&charShort length:1]];
        });
        return str;
    }copy]autorelease];
}
@dynamic elementAt;
-(id (^)(int))elementAt
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(int index) {
        id item = [weakSelf.toArray() objectAtIndex:index];
        if(item)
        {
            return item;
        } else {
            [[NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"Result returned -1.."
                                   userInfo:nil]
             raise];
            return (id)nil;
        }
    }copy]autorelease];
}

@dynamic elementOrNilAt;
-(id (^)(int))elementOrNilAt
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(int index) {
        return [weakSelf.toArray() objectAtIndex:index];
    }copy]autorelease];
}

@dynamic single;
-(id (^)())single
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^() {
        id item = [weakSelf nextObject];
        if(item && [weakSelf nextObject] == nil) {
            return item;
        } else {
            [[NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"Result returned -1.."
                                   userInfo:nil]
             raise];
            return (id)nil;
        }
    }copy]autorelease];
}

@dynamic singleWithPredicate;
-(id (^)(BOOL(^)(id)))singleWithPredicate
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = [[predicate copy]autorelease];
        return weakSelf.where(_predicate).single();
    }copy]autorelease];
}

@dynamic singleOrNil;
-(id (^)())singleOrNil
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^() {
        id item = [weakSelf nextObject];
        if([weakSelf nextObject] == nil) {
            return item;
        } else {
            [[NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"Result returned -1.."
                                   userInfo:nil]
             raise];
        return (id)nil;
        }
    }copy]autorelease];
}

@dynamic singleOrNilWithPredicate;
-(id (^)(BOOL(^)(id)))singleOrNilWithPredicate
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = [[predicate copy]autorelease];
        return weakSelf.where(_predicate).singleOrNil();
    }copy]autorelease];
}

@dynamic first;
-(id (^)())first
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^() {
        id item = [weakSelf nextObject];
        if(item) {
            return item;
        } else {
            [[NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"Result returned -1.."
                                   userInfo:nil]
             raise];
            return (id)nil;
        }
    }copy]autorelease];
}

@dynamic firstWithPredicate;
-(id (^)(BOOL(^)(id)))firstWithPredicate
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = [[predicate copy]autorelease];
        return weakSelf.where(_predicate).first();
    }copy]autorelease];
}

@dynamic firstOrNil;
-(id (^)())firstOrNil
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^() {
        return [weakSelf nextObject];
    }copy]autorelease];
}

@dynamic firstOrNilWithPredicate;
-(id (^)(BOOL(^)(id)))firstOrNilWithPredicate
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = [[predicate copy]autorelease];
        return weakSelf.where(_predicate).firstOrNil();
    }copy]autorelease];    
}

@dynamic last;
-(id (^)())last
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^() {
        id item = [weakSelf.toArray() lastObject];
        if(item) {
            return item;
        } else {
            [[NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"Result returned -1.."
                                   userInfo:nil]
             raise];
            return (id)nil;
        }
    }copy]autorelease];
}

@dynamic lastWithPredicate;
-(id (^)(BOOL(^)(id)))lastWithPredicate
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = [[predicate copy]autorelease];
        return weakSelf.where(_predicate).last();
    }copy]autorelease];
}

@dynamic lastOrNil;
-(id (^)())lastOrNil
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^() {
        return [weakSelf.toArray() lastObject];
    }copy]autorelease];
}

@dynamic lastOrNilWithPredicate;
-(id (^)(BOOL(^)(id)))lastOrNilWithPredicate
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = [[predicate copy]autorelease];
        return weakSelf.where(_predicate).lastOrNil();
    }copy]autorelease];
}

@dynamic count;
-(int (^)())count
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^() {
        return weakSelf.toArray().count;
    }copy]autorelease];
}

@dynamic all;
-(BOOL (^)(BOOL(^)(id)))all
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = [[predicate copy]autorelease];
        id item;
        while ((item = [weakSelf nextObject]))
        {
            if(!_predicate(item))
                return NO;
        }
        return YES;
    }copy]autorelease];
}

@dynamic any;
-(BOOL (^)(BOOL(^)(id)))any
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = [[predicate copy]autorelease];
        id item;
        while ((item = [weakSelf nextObject]))
        {
            if(_predicate(item))
                return YES;
        }
        return NO;
    }copy]autorelease];
}

@dynamic contains;
-(BOOL (^)(id))contains
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(id item) {
        id dst;
        while ((dst = [weakSelf nextObject]))
        {
            if([dst isEqual:(item)])
                return YES;
        }
        return NO;
    }copy]autorelease];
}

@dynamic sequenceEqual;
-(BOOL (^)(NSEnumerator *))sequenceEqual
{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(NSEnumerator *dst) {
        return [weakSelf.toArray() isEqualToArray:dst.toArray()];
    }copy]autorelease];
}

@dynamic forEach;
- (void (^)(void(^)(id)))forEach{
    __unsafe_unretained NSEnumerator *weakSelf = self;
    return [[^(void(^action)(id)) {
        void (^_action)(id) = [[action copy]autorelease];
        for (id value in weakSelf) {
            _action(value);
        }
    }copy]autorelease];
}

//従来のメソッドバージョン
#else

@implementation NSData (Query)

-(NSEnumerator *)objectEnumerator {
    __unsafe_unretained NSData *weakSelf = self;
    __block int counter = 0;
    
    return [[[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        while (counter < [weakSelf length]) {
            
            return [NSNumber numberWithChar:(*((char *)([weakSelf bytes] + counter++)))];
        }
        return nil;
    }] autorelease];
}

@end

@implementation NSString (Query)

-(NSEnumerator *)objectEnumerator {
    __unsafe_unretained NSString *weakSelf = self;
    __block int counter = 0;
    
    return [[[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        while (counter < [weakSelf length]) {
            return [NSNumber numberWithUnsignedShort:[weakSelf characterAtIndex:counter++]];
        }
        return nil;
    }] autorelease];
}

@end

@implementation NSEnumerator (Query)

+(NSEnumerator *)range:(int)start to:(int)count {
    __block int counter = start;
    return [[[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        while (counter < (start + count)) {
            return [NSNumber numberWithInt:counter++];
        }
        return nil;
    }] autorelease];
}


+(NSEnumerator *)repeat:(id)item count:(int)count {
    __block int counter = 0;
    return [[[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        while (counter < count) {
            counter++;
            return item;
        }
        return nil;
    }] autorelease];
}

+(NSEnumerator *)empty {
    return [[[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        return nil;
    }] autorelease];
}

- (NSEnumerator *) ofClass: (Class) classType
{
    return [[[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        do {
            item = [src nextObject];
        } while (item != nil && ![item isKindOfClass:classType]);
        
        return item;
    }] autorelease];
}


-(NSEnumerator *) select: (id(^)(id)) selector
{
    id (^_selector)(id) = [[selector copy]autorelease];
    return [self selectWithIndex:^id(id item, int index) {
        return _selector(item);
    }] ;
}


-(NSEnumerator *) selectWithIndex: (id(^)(id,int)) selector
{
    __block int counter = 0;
    id (^_selector)(id,int) = [[selector copy]autorelease];
    return [[[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        while ((item = [src nextObject]))
        {
            return _selector(item,counter++);
        }
        return nil;
    }] autorelease];
}


-(NSEnumerator *) where: (BOOL(^)(id)) predicate
{
    BOOL (^_predicate)(id) = [[predicate copy]autorelease];
    return [self whereWithIndex:^BOOL(id item, int index) {
        return _predicate(item);
    }];
}


-(NSEnumerator *) whereWithIndex: (BOOL(^)(id,int)) predicate
{
    __block int counter = 0;
    BOOL (^_predicate)(id,int) = [[predicate copy]autorelease];
    return [[[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        while ((item = [src nextObject]))
        {
            if(_predicate(item,counter++))
                return item;
        }
        return nil;
    }] autorelease];
}


-(NSEnumerator *) skip: (int)count
{
    __block int counter = 0;
    return [[[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        while (counter++ < count)
        {
            if(!(item = [src nextObject]))
                return nil;
        }
        return [src nextObject];
    }] autorelease];
}


-(NSEnumerator *) skipWhile: (BOOL(^)(id item)) predicate
{
    BOOL (^_predicate)(id) = [[predicate copy]autorelease];
    return [self skipWhileWithIndex:^BOOL(id item, int index) {
        return _predicate(item);
    }];
}


-(NSEnumerator *) skipWhileWithIndex: (BOOL(^)(id,int)) predicate
{
    __block int counter = 0;
    __block BOOL skipped = NO;
    BOOL (^_predicate)(id,int) = [[predicate copy]autorelease];
    return [[[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
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
    }] autorelease];
}


-(NSEnumerator *) take: (int)count
{
    __block int counter = 0;
    return [[[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        if (counter++ < count && (item = [src nextObject]))
        {
            return item;
        }
        return nil;
    }] autorelease];
}


-(NSEnumerator *) takeWhile: (BOOL(^)(id item)) predicate
{
    BOOL (^_predicate)(id) = [[predicate copy]autorelease];
    return [self takeWhileWithIndex:^BOOL(id item, int index) {
        return _predicate(item);
    }];
}


-(NSEnumerator *) takeWhileWithIndex: (BOOL(^)(id,int)) predicate
{
    __block int counter = 0;
    __block BOOL taking = YES;
    BOOL (^_predicate)(id,int) = [[predicate copy]autorelease];
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

-(NSEnumerator *) scan: (id(^)(id,id)) func {
    id (^_func)(id,id) = [[func copy]autorelease];
    __block BOOL first = YES;
    __block id result;
    return [[[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        while ((item = [src nextObject]))
        {
            if (first) {
                result = item;
                first = NO;
            } else {
                result = _func(result, item);
            }
            return result;
        }
        return nil;
    }] autorelease];
}

-(NSEnumerator *)orderByDescription:(NSSortDescriptor *)firstObj, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list list;
    va_start(list, firstObj);
    NSMutableArray *array = [[[NSMutableArray alloc]initWithObjects:firstObj, nil] autorelease];
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
    id (^_selector)(id) = [[selector copy]autorelease];
    __block id current = [self nextObject];
    return [[[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        while ((item = [current nextObject]))
        {
            return _selector(item);
        }
        if((current = [src nextObject]))
        {
            return [current nextObject];
        }
        return nil;
    }] autorelease];
}

- (NSEnumerator *) distinct{
    
    __block NSMutableArray *returnedArray = [[NSMutableArray alloc]init];
    return [[[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
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
    }] autorelease];
}

- (NSEnumerator *) concat:(NSEnumerator *)dst
{
    NSEnumerator *_dst = dst;
    __block BOOL isFirst = true;
    return [[[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        if (isFirst)
        {
            if((item = [src nextObject]))
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
    }] autorelease];
}


- (NSEnumerator *) unions:(NSEnumerator *)dst{
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
    return [[[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        NSArray *result = [[src take:count]toArray];
        return (result.count == 0) ? nil: result;
    }] autorelease];
}

- (NSArray*) toArray
{
    return [self allObjects];
}

- (NSMutableArray*) toMutableArray
{
    NSMutableArray *result = [[[NSMutableArray alloc]init] autorelease];
    for (id value in self) {
        [result addObject:value];
    }
    return result;
}

- (NSDictionary *) toDictionary: (id(^)(id)) keySelector{
    
    NSArray* objArray = [self toArray];
    NSArray* keyArray = [[[objArray objectEnumerator] select:^id(id item) {
        return keySelector(item);
    }]toArray];
    return [[[NSDictionary alloc]initWithObjects:objArray forKeys:keyArray] autorelease];
}

- (NSDictionary *) toDictionary: (id(^)(id)) keySelector elementSelector:(id(^)(id)) elementSelector{
    NSArray* objArray = [self toArray];
    NSArray* keyArray = [[[objArray objectEnumerator]select:^id(id item) {
        return keySelector(item);
    }]toArray];
    NSArray* elementArray = [[[objArray objectEnumerator] select:^id(id item) {
        return elementSelector(item);
    }]toArray];
    return [[[NSDictionary alloc]initWithObjects:elementArray forKeys:keyArray] autorelease];
}

- (NSMutableDictionary *) toMutableDictionary: (id(^)(id)) keySelector{
    
    NSArray* objArray = [self toArray];
    NSArray* keyArray = [[[objArray objectEnumerator] select:^id(id item) {
        return keySelector(item);
    }]toArray];
    return [[[NSMutableDictionary alloc]initWithObjects:objArray forKeys:keyArray] autorelease];
}

- (NSMutableDictionary *) toMutableDictionary: (id(^)(id)) keySelector elementSelector:(id(^)(id)) elementSelector{
    NSArray* objArray = [self toArray];
    NSArray* keyArray = [[[objArray objectEnumerator]select:^id(id item) {
        return keySelector(item);
    }]toArray];
    NSArray* elementArray = [[[objArray objectEnumerator] select:^id(id item) {
        return elementSelector(item);
    }]toArray];
    return [[[NSMutableDictionary alloc]initWithObjects:elementArray forKeys:keyArray] autorelease];
}

-(NSData *) toData {
    NSArray * array = [self allObjects];
    NSMutableData *result = [[[NSMutableData alloc]initWithCapacity:[array count]] autorelease];
    for (NSNumber * obj in array) {
        char charByte = [obj charValue];
        [result appendBytes:&charByte length:1];
    }
    return result;
}

-(NSString *) toString {
    __block NSString *str = [[[NSString alloc]init] autorelease];
    [self forEach:^(id number) {
        unichar charShort = [(NSNumber*)number unsignedShortValue];
        [str stringByAppendingString:[NSString stringWithCharacters:&charShort length:1]];
    }];
    return str;
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

#endif

@end