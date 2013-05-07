//
//  NSEnumerator+Query.m
//

#import "NSEnumerator+Query.h"


@implementation CustomEnumerator


- (id)initWithFunction:(NSEnumerator *)src nextObjectBlock:(id(^)(NSEnumerator *))nextObject {
    self = [super init];
    if(self) {
        _src = src;
        _nextObject = AH_AUTORELEASE([nextObject copy]);
    }
    return self;
}


- (id)nextObject {
    return _nextObject(_src);
}

@end

//メソッドチェインバージョン
#ifdef USE_METHOD_CHAIN

@implementation NSData (Query)

@dynamic getEnumerator;
-(NSEnumerator *(^)())getEnumerator {
    __weak NSData *weakSelf = self;
    return AH_AUTORELEASE([^() {
        __block int counter = 0;
        return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
            while (counter < [weakSelf length]) {
                
                return [NSNumber numberWithChar:(*((char *)([weakSelf bytes] + counter++)))];
            }
            return nil;
        }]);
    }copy]);
}

@end

@implementation NSString (Query)

@dynamic getEnumerator;
-(NSEnumerator *(^)())getEnumerator {
    __weak NSString *weakSelf = self;
    return AH_AUTORELEASE([^() {
        __block int counter = 0;
        
        return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
            while (counter < [weakSelf length]) {
                return [NSNumber numberWithUnsignedShort:[weakSelf characterAtIndex:counter++]];
            }
            return nil;
        }]);
    }copy]);
}

@end

@implementation NSArray (Query)

@dynamic getEnumerator;
-(NSEnumerator *(^)())getEnumerator {
    __weak NSArray *weakSelf = self;
    return AH_AUTORELEASE([^() {
        return [weakSelf objectEnumerator];
    }copy]);
}

@end

@implementation NSDictionary (Query)

@dynamic getEnumerator;
-(NSEnumerator *(^)())getEnumerator {
    __weak NSDictionary *weakSelf = self;
    return AH_AUTORELEASE([^() {
        return [weakSelf objectEnumerator];
    }copy]);
}

@dynamic getKeyEnumerator;
-(NSEnumerator *(^)())getKeyEnumerator {
    __weak NSDictionary *weakSelf = self;
    return AH_AUTORELEASE([^() {
        return [weakSelf keyEnumerator];
    }copy]);
}

@end


@implementation NSEnumerator (Query)

+(NSEnumerator *)range:(int)start to:(int)count {
    __block int counter = start;
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        while (counter < (start + count)) {
            return [NSNumber numberWithInt:counter++];
        }
        return nil;
    }]);
}


+(NSEnumerator *)repeat:(id)item count:(int)count {
    __block int counter = 0;
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        while (counter < count) {
            counter++;
            return item;
        }
        return nil;
    }]);
}

+(NSEnumerator *)empty {
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        return nil;
    }]);
}

@dynamic ofClass;
- (NSEnumerator *(^)(Class))ofClass {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^NSEnumerator *(Class classType) {
        return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
            id item;
            do {
                item = [src nextObject];
            } while (item != nil && ![item isKindOfClass:classType]);
            
            return item;
        }]);
    }copy]);
}

@dynamic select;
-(NSEnumerator *(^)(id(^)(id)))select {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(id (^selector)(id)) {
        id (^_selector)(id) = AH_AUTORELEASE([selector copy]);
        return weakSelf.selectWithIndex(^id(id item, int index) {
            return _selector(item);
        });
    }copy]);
}

@dynamic selectWithIndex;
-(NSEnumerator *(^)(id(^)(id,int)))selectWithIndex {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(id(^selector)(id,int)) {
        __block int counter = 0;
        id (^_selector)(id,int) = AH_AUTORELEASE([selector copy]);
        return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
            id item;
            while ((item = [src nextObject]))
            {
                return _selector(item,counter++);
            }
            return nil;
        }]);
    }copy]);
}

@dynamic where;
-(NSEnumerator *(^)(BOOL(^)(id)))where {
    __weak NSEnumerator *weakSelf = self;
    return [[^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = AH_AUTORELEASE([predicate copy]);
        return weakSelf.whereWithIndex(^BOOL(id item, int index) {
            return _predicate(item);
        });
    }copy];
}
            
@dynamic whereWithIndex;
-(NSEnumerator *(^)(BOOL(^)(id,int)))whereWithIndex {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(BOOL(^predicate)(id,int)) {
        __block int counter = 0;
        BOOL (^_predicate)(id,int) = AH_AUTORELEASE([predicate copy]);
        return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
            id item;
            while ((item = [src nextObject]))
            {
                if(_predicate(item,counter++))
                    return item;
            }
            return nil;
        }]);
    }copy]);
}

@dynamic skip;
-(NSEnumerator *(^)(int))skip {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(int count) {
        __block int counter = 0;
        return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
            id item;
            while (counter++ < count)
            {
                if(!(item = [src nextObject]))
                    return nil;
            }
            return [src nextObject];
        }]);
    }copy]);
}

@dynamic skipWhile;
-(NSEnumerator *(^)(BOOL(^)(id)))skipWhile {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = AH_AUTORELEASE([predicate copy]);
        return weakSelf.skipWhileWithIndex(^BOOL(id item, int index) {
            return _predicate(item);
        });
    }copy]);
    
}

@dynamic skipWhileWithIndex;
-(NSEnumerator *(^)(BOOL(^)(id,int)))skipWhileWithIndex {
    __weak NSEnumerator *weakSelf = self;
    return [[^(BOOL(^predicate)(id,int)) {
        __block int counter = 0;
        __block BOOL skipped = NO;
        BOOL (^_predicate)(id,int) = AH_AUTORELEASE([predicate copy]);
        return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
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
        }]);
    }copy]);
}

@dynamic take;
-(NSEnumerator *(^)(int))take {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(int count) {
        __block int counter = 0;
        return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
            id item;
            if (counter++ < count && (item = [src nextObject]))
            {
                return item;
            }
            return nil;
        }]);
    }copy]);
}

@dynamic takeWhile;
-(NSEnumerator *(^)(BOOL(^)(id)))takeWhile {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(BOOL(^predicate)(id)) {
        return weakSelf.takeWhileWithIndex(^BOOL(id item, int index) {
            return predicate(item);
        });
    }copy]);
}

@dynamic takeWhileWithIndex;
-(NSEnumerator *(^)(BOOL(^)(id,int)))takeWhileWithIndex {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(BOOL(^predicate)(id,int)) {
        __block int counter = 0;
        __block BOOL taking = YES;
        BOOL (^_predicate)(id,int) = AH_AUTORELEASE([predicate copy]);
        return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
            id item;
            if (taking && (item = [src nextObject]))
            {
                while ((taking = _predicate(item,counter++)))
                {
                    return item;
                }
            }
            return nil;
        }]);
    }copy]);
}

@dynamic scan;
-(NSEnumerator *(^)(id(^)(id,id)))scan {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(id(^accumlator)(id, id)) {
        id (^_accumlator)(id,id) = AH_AUTORELEASE([accumlator copy]);
        __block BOOL first = YES;
        __block id result;
        return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
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
        }]);
    }copy]);
}

@dynamic orderByDescription;
-(NSEnumerator *(^)(NSSortDescriptor *, ...))orderByDescription {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(NSSortDescriptor *firstObj, ...) {
        va_list list;
        va_start(list, firstObj);
        NSMutableArray *array = AH_AUTORELEASE([[NSMutableArray alloc]initWithObjects:firstObj, nil]);
        NSSortDescriptor *desc;
        while((desc = va_arg(list, NSSortDescriptor*)))
        {
            [array addObject:desc];
        }
        va_end(list);
        NSArray *result = weakSelf.toArray();
        return [result sortedArrayUsingDescriptors:array].getEnumerator();
    }copy]);
}

@dynamic selectMany;
- (NSEnumerator *(^)(id(^)(id)))selectMany {
    __weak NSEnumerator *weakSelf = self;
    return [[^(id(^selector)(id)) {
        id (^_selector)(id) = AH_AUTORELEASE([selector copy]);
        __block id current = [self nextObject];
        return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
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
        }]);
    }copy]);
}
                                    
@dynamic distinct;
- (NSEnumerator *(^)())distinct {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^() {
        __block NSMutableArray *returnedArray = [[NSMutableArray alloc]init];
        return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
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
        }]);
    }copy]);
}

@dynamic concat;
- (NSEnumerator *(^)(NSEnumerator *))concat {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(NSEnumerator *dst) {
        __block BOOL isFirst = true;
        return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
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
        }]);
    }copy]);
}

@dynamic unions;
- (NSEnumerator *(^)(NSEnumerator *))unions {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(NSEnumerator *dst) {
        return weakSelf.concat(dst).distinct();
    }copy]);
}

@dynamic intersect;
- (NSEnumerator *(^)(NSEnumerator *))intersect {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(NSEnumerator *dst) {
        NSArray *dstArray = dst.toArray();
        return weakSelf.where(^BOOL(id item) {
            return [dstArray containsObject:item];
        });
    }copy]);
}

@dynamic except;
- (NSEnumerator *(^)(NSEnumerator *))except {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(NSEnumerator *dst) {
        NSArray *dstArray = dst.toArray();
        return weakSelf.where(^BOOL(id item) {
            return ![dstArray containsObject:item];
        });
    }copy]);
}

@dynamic buffer;
- (NSEnumerator *(^)(int))buffer {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(int count) {
        return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:weakSelf nextObjectBlock:^id(NSEnumerator *src) {
            NSArray *result = src.take(count).toArray();
            return (result.count == 0) ? nil: result;
        }]);
    }copy]);
}

@dynamic toArray;
- (NSArray*(^)())toArray {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^() {
        return [weakSelf allObjects];
    }copy]);
}

@dynamic toMutableArray;
- (NSMutableArray*(^)())toMutableArray {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^() {
        NSMutableArray *result = AH_AUTORELEASE([[NSMutableArray alloc]init]);
        for (id value in weakSelf) {
            [result addObject:value];
        }
        return result;
    }copy]);
}

@dynamic toDictionary;
- (NSDictionary *(^)(id(^)(id)))toDictionary {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(id(^keySelector)(id)) {
        NSArray* objArray = weakSelf.toArray();
        NSArray* keyArray = objArray.getEnumerator()
        .select(^id(id item) { return keySelector(item); })
        .toArray();
        return AH_AUTORELEASE([[NSDictionary alloc]initWithObjects:objArray forKeys:keyArray]);
    }copy]);
}

@dynamic toDictionaryWithSelector;
- (NSDictionary *(^)(id(^)(id), id(^)(id)))toDictionaryWithSelector {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(id(^keySelector)(id), id(^elementSelector)(id)) {
        NSArray* objArray = weakSelf.toArray();
        NSArray* keyArray = objArray.getEnumerator()
        .select(^id(id item) { return keySelector(item); })
        .toArray();
        NSArray* elementArray = objArray.getEnumerator()
        .select(^id(id item) { return elementSelector(item); })
        .toArray();
        return AH_AUTORELEASE([[NSDictionary alloc]initWithObjects:elementArray forKeys:keyArray]);
    }copy]);
}

@dynamic toMutableDictionary;
- (NSMutableDictionary *(^)(id(^)(id)))toMutableDictionary {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(id(^keySelector)(id)) {
        NSArray* objArray = weakSelf.toArray();
        NSArray* keyArray = objArray.getEnumerator()
        .select(^id(id item) { return keySelector(item); })
        .toArray();
        return AH_AUTORELEASE([[NSMutableDictionary alloc]initWithObjects:objArray forKeys:keyArray]);
    }copy]);
}

@dynamic toMutableDictionaryWithSelector;
- (NSMutableDictionary *(^)(id(^)(id), id(^)(id)))toMutableDictionaryWithSelector {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(id(^keySelector)(id), id(^elementSelector)(id)) {
        NSArray* objArray = weakSelf.toArray();
        NSArray* keyArray = objArray.getEnumerator()
        .select(^id(id item) { return keySelector(item);})
        .toArray();
        NSArray* elementArray = objArray.getEnumerator()
        .select(^id(id item) { return elementSelector(item); })
        .toArray();
        return AH_AUTORELEASE([[NSMutableDictionary alloc]initWithObjects:elementArray forKeys:keyArray]);
    }copy]);
}

@dynamic toData;
-(NSData *(^)())toData {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^() {
        NSArray * array = [weakSelf allObjects];
        NSMutableData *result = AH_AUTORELEASE([[NSMutableData alloc]initWithCapacity:[array count]]);
        for (NSNumber * obj in array) {
            char charByte = [obj charValue];
            [result appendBytes:&charByte length:1];
        }
        return result;
    }copy]);
}

@dynamic toString;
-(NSString *(^)())toString {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^() {
        __block NSString *str = AH_AUTORELEASE([[NSString alloc]init]);
        weakSelf.forEach(^(id number) {
            unichar charShort = [(NSNumber*)number unsignedShortValue];
            [str stringByAppendingString:[NSString stringWithCharacters:&charShort length:1]];
        });
        return str;
    }copy]);
}

@dynamic elementAt;
-(id (^)(int))elementAt {
    __weak NSEnumerator *weakSelf = self;
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
    }copy]);
}

@dynamic elementOrNilAt;
-(id (^)(int))elementOrNilAt {
    __weak NSEnumerator *weakSelf = self;
    return [[^(int index) {
        return [weakSelf.toArray() objectAtIndex:index];
    }copy]);
}

@dynamic single;
-(id (^)())single {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^() {
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
    }copy]);
}

@dynamic singleWithPredicate;
-(id (^)(BOOL(^)(id)))singleWithPredicate {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = AH_AUTORELEASE([predicate copy]);
        return weakSelf.where(_predicate).single();
    }copy]);
}

@dynamic singleOrNil;
-(id (^)())singleOrNil {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^() {
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
    }copy]);
}

@dynamic singleOrNilWithPredicate;
-(id (^)(BOOL(^)(id)))singleOrNilWithPredicate {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = AH_AUTORELEASE([predicate copy]);
        return weakSelf.where(_predicate).singleOrNil();
    }copy]);
}

@dynamic first;
-(id (^)())first {
    __weak NSEnumerator *weakSelf = self;
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
    }copy]);
}

@dynamic firstWithPredicate;
-(id (^)(BOOL(^)(id)))firstWithPredicate {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = AH_AUTORELEASE([predicate copy]);
        return weakSelf.where(_predicate).first();
    }copy]);
}

@dynamic firstOrNil;
-(id (^)())firstOrNil {
    __weak NSEnumerator *weakSelf = self;
    return [[^() {
        return [weakSelf nextObject];
    }copy]);
}

@dynamic firstOrNilWithPredicate;
-(id (^)(BOOL(^)(id)))firstOrNilWithPredicate {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = AH_AUTORELEASE([predicate copy]);
        return weakSelf.where(_predicate).firstOrNil();
    }copy]);
}

@dynamic last;
-(id (^)())last {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^() {
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
    }copy]);
}

@dynamic lastWithPredicate;
-(id (^)(BOOL(^)(id)))lastWithPredicate {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = AH_AUTORELEASE([predicate copy]);
        return weakSelf.where(_predicate).last();
    }copy]);
}

@dynamic lastOrNil;
-(id (^)())lastOrNil {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^() {
        return [weakSelf.toArray() lastObject];
    }copy]);
}

@dynamic lastOrNilWithPredicate;
-(id (^)(BOOL(^)(id)))lastOrNilWithPredicate {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = AH_AUTORELEASE([predicate copy]);
        return weakSelf.where(_predicate).lastOrNil();
    }copy]);
}

@dynamic count;
-(int (^)())count {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^() {
        return weakSelf.toArray().count;
    }copy]);
}

@dynamic all;
-(BOOL (^)(BOOL(^)(id)))all {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = AH_AUTORELEASE([predicate copy]);
        id item;
        while ((item = [weakSelf nextObject]))
        {
            if(!_predicate(item))
                return NO;
        }
        return YES;
    }copy]);
}

@dynamic any;
-(BOOL (^)(BOOL(^)(id)))any {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(BOOL(^predicate)(id)) {
        BOOL (^_predicate)(id) = AH_AUTORELEASE([predicate copy]);
        id item;
        while ((item = [weakSelf nextObject]))
        {
            if(_predicate(item))
                return YES;
        }
        return NO;
    }copy]);
}

@dynamic contains;
-(BOOL (^)(id))contains {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(id item) {
        id dst;
        while ((dst = [weakSelf nextObject]))
        {
            if([dst isEqual:(item)])
                return YES;
        }
        return NO;
    }copy]);
}

@dynamic sequenceEqual;
-(BOOL (^)(NSEnumerator *))sequenceEqual {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(NSEnumerator *dst) {
        return [weakSelf.toArray() isEqualToArray:dst.toArray()];
    }copy]);
}

@dynamic forEach;
- (void (^)(void(^)(id)))forEach {
    __weak NSEnumerator *weakSelf = self;
    return AH_AUTORELEASE([^(void(^action)(id)) {
        void (^_action)(id) = AH_AUTORELEASE([action copy]);
        for (id value in weakSelf) {
            _action(value);
        }
    }copy]);
}

@dynamic forEachWithIndex;
- (void (^)(void(^)(id,int)))forEach {
    __weak NSEnumerator *weakSelf = self;
    __block int counter = 0;
    return AH_AUTORELEASE([^(void(^action)(id,int)) {
        void (^_action)(id) = AH_AUTORELEASE([action copy]);
        for (id value in weakSelf) {
            _action(value,counter++);
        }
    }copy]);
}

//従来のメソッドバージョン
#else

@implementation NSData (Query)

-(NSEnumerator *)objectEnumerator {
    __my_block_weak NSData *weakSelf = self;
    __block int counter = 0;
    
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        while (counter < [weakSelf length]) {
            
            return [NSNumber numberWithChar:(*((char *)([weakSelf bytes] + counter++)))];
        }
        return nil;
    }]);
}

@end

@implementation NSString (Query)

-(NSEnumerator *)objectEnumerator {
    __my_block_weak NSString *weakSelf = self;
    __block int counter = 0;
    
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        while (counter < [weakSelf length]) {
            return [NSNumber numberWithUnsignedShort:[weakSelf characterAtIndex:counter++]];
        }
        return nil;
    }]);
}

@end

@implementation NSEnumerator (Query)

+(NSEnumerator *)range:(int)start to:(int)count {
    __block int counter = start;
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        while (counter < (start + count)) {
            return [NSNumber numberWithInt:counter++];
        }
        return nil;
    }]);
}


+(NSEnumerator *)repeat:(id)item count:(int)count {
    __block int counter = 0;
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        while (counter < count) {
            counter++;
            return item;
        }
        return nil;
    }]);
}

+(NSEnumerator *)empty {
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:nil nextObjectBlock:^id(NSEnumerator * src) {
        return nil;
    }]);
}

- (NSEnumerator *)ofClass:(Class)classType {
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        do {
            item = [src nextObject];
        } while (item != nil && ![item isKindOfClass:classType]);
        return item;
    }]);
}


-(NSEnumerator *)select:(id(^)(id))selector {
    id (^_selector)(id) = AH_AUTORELEASE([selector copy]);
    return [self selectWithIndex:^id(id item, int index) {
        return _selector(item);
    }];
}


-(NSEnumerator *)selectWithIndex:(id(^)(id,int))selector {
    __block int counter = 0;
    id (^_selector)(id,int) = AH_AUTORELEASE([selector copy]);
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        while ((item = [src nextObject])) {
            return _selector(item,counter++);
        }
        return nil;
    }]);
}


-(NSEnumerator *)where:(BOOL(^)(id))predicate {
    BOOL (^_predicate)(id) = AH_AUTORELEASE([predicate copy]);
    return [self whereWithIndex:^BOOL(id item, int index) {
        return _predicate(item);
    }];
}


-(NSEnumerator *)whereWithIndex:(BOOL(^)(id,int))predicate {
    __block int counter = 0;
    BOOL (^_predicate)(id,int) = AH_AUTORELEASE([predicate copy]);
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        while ((item = [src nextObject])) {
            if(_predicate(item,counter++))
                return item;
        }
        return nil;
    }]);
}


-(NSEnumerator *)skip:(int)count {
    __block int counter = 0;
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        while (counter++ < count) {
            if(!(item = [src nextObject]))
                return nil;
        }
        return [src nextObject];
    }]);
}


-(NSEnumerator *)skipWhile:(BOOL(^)(id item))predicate {
    BOOL (^_predicate)(id) = AH_AUTORELEASE([predicate copy]);
    return [self skipWhileWithIndex:^BOOL(id item, int index) {
        return _predicate(item);
    }];
}


-(NSEnumerator *)skipWhileWithIndex:(BOOL(^)(id,int))predicate {
    __block int counter = 0;
    __block BOOL skipped = NO;
    BOOL (^_predicate)(id,int) = AH_AUTORELEASE([predicate copy]);
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        if (!skipped) {
            do {
                if(!(item = [src nextObject]))
                    return nil;
            } while (_predicate(item,counter++));
            skipped = YES;
            return item;
        }
        return [src nextObject];
    }]);
}


-(NSEnumerator *)take:(int)count {
    __block int counter = 0;
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        if (counter++ < count && (item = [src nextObject])) {
            return item;
        }
        return nil;
    }]);
}


-(NSEnumerator *)takeWhile:(BOOL(^)(id item))predicate {
    BOOL (^_predicate)(id) = AH_AUTORELEASE([predicate copy]);
    return [self takeWhileWithIndex:^BOOL(id item, int index) {
        return _predicate(item);
    }];
}


-(NSEnumerator *)takeWhileWithIndex:(BOOL(^)(id,int))predicate {
    __block int counter = 0;
    __block BOOL taking = YES;
    BOOL (^_predicate)(id,int) = AH_AUTORELEASE([predicate copy]);
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        if (taking && (item = [src nextObject])) {
            while ((taking = _predicate(item,counter++))) {
                return item;
            }
        }
        return nil;
    }]);
}

-(NSEnumerator *)scan:(id(^)(id,id))func {
    id (^_func)(id,id) = AH_AUTORELEASE([func copy]);
    __block BOOL first = YES;
    __block id result;
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        while ((item = [src nextObject])) {
            if (first) {
                result = item;
                first = NO;
            } else {
                result = _func(result, item);
            }
            return result;
        }
        return nil;
    }]);
}

-(NSEnumerator *)orderByDescription:(NSSortDescriptor *)firstObj, ... {
    va_list list;
    va_start(list, firstObj);
    NSMutableArray *array = [[NSMutableArray alloc]initWithObjects:firstObj, nil];
    NSSortDescriptor *desc;
    while((desc = va_arg(list, NSSortDescriptor*))) {
        [array addObject:desc];
    }
    va_end(list);
    NSArray *result = [self toArray];
    return [[result sortedArrayUsingDescriptors:array]objectEnumerator];
}


-(NSEnumerator *)selectMany:(id(^)(id))selector {
    id (^_selector)(id) = AH_AUTORELEASE([selector copy]);
    __block id current = [self nextObject];
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        while ((item = [current nextObject])) {
            return _selector(item);
        }
        if((current = [src nextObject])) {
            return [current nextObject];
        }
        return nil;
    }]);
}

-(NSEnumerator *)distinct{    
    __block NSMutableArray *returnedArray = [[NSMutableArray alloc]init];
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        while((item = [src nextObject]) != nil && [returnedArray containsObject:item]){
            NSLog(@"skip : %@",item);
        }
        if(item) {
            NSLog(@"return %@",item);
            [returnedArray addObject:item];
            return item;
        }
        return item;
    }]);
}

-(NSEnumerator *)concat:(NSEnumerator *)dst {
    NSEnumerator *_dst = dst;
    __block BOOL isFirst = true;
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        id item;
        if (isFirst) {
            if((item = [src nextObject])) {
                return item;
            } else {
                isFirst = false;
                return [_dst nextObject];
            }
        } else {
            return [_dst nextObject];
        }
    }]);
}


-(NSEnumerator *)unions:(NSEnumerator *)dst{
    return [[self concat:dst]distinct];
}

-(NSEnumerator *)intersect:(NSEnumerator *)dst{
    NSArray *dstArray = [dst toArray];
    return [self where:^BOOL(id item) {
        return [dstArray containsObject:item];
    }];
}

-(NSEnumerator *)except:(NSEnumerator *)dst{
    NSArray *dstArray = [dst toArray];
    return [self where:^BOOL(id item) {
        return ![dstArray containsObject:item];
    }];
}

-(NSEnumerator *)buffer:(int)count; {
    return AH_AUTORELEASE([[CustomEnumerator alloc]initWithFunction:self nextObjectBlock:^id(NSEnumerator *src) {
        NSArray *result = [[src take:count]toArray];
        return (result.count == 0) ? nil: result;
    }]);
}

-(NSArray*) toArray {
    return [self allObjects];
}

-(NSMutableArray*) toMutableArray {
    NSMutableArray *result = AH_AUTORELEASE([[NSMutableArray alloc]init]);
    for (id value in self) {
        [result addObject:value];
    }
    return result;
}

-(NSDictionary *)toDictionary:(id(^)(id))keySelector {
    NSArray* objArray = [self toArray];
    NSArray* keyArray = [[[objArray objectEnumerator] select:^id(id item) {
        return keySelector(item);
    }]toArray];
    return AH_AUTORELEASE([[NSDictionary alloc]initWithObjects:objArray forKeys:keyArray]);
}

-(NSDictionary *)toDictionary:(id(^)(id))keySelector elementSelector:(id(^)(id))elementSelector{
    NSArray* objArray = [self toArray];
    NSArray* keyArray = [[[objArray objectEnumerator]select:^id(id item) {
        return keySelector(item);
    }]toArray];
    NSArray* elementArray = [[[objArray objectEnumerator] select:^id(id item) {
        return elementSelector(item);
    }]toArray];
    return AH_AUTORELEASE([[NSDictionary alloc]initWithObjects:elementArray forKeys:keyArray]);
}

-(NSMutableDictionary *)toMutableDictionary:(id(^)(id))keySelector {
    NSArray* objArray = [self toArray];
    NSArray* keyArray = [[[objArray objectEnumerator] select:^id(id item) {
        return keySelector(item);
    }]toArray];
    return AH_AUTORELEASE([[NSMutableDictionary alloc]initWithObjects:objArray forKeys:keyArray]);
}

-(NSMutableDictionary *)toMutableDictionary:(id(^)(id))keySelector elementSelector:(id(^)(id))elementSelector {
    NSArray* objArray = [self toArray];
    NSArray* keyArray = [[[objArray objectEnumerator]select:^id(id item) {
        return keySelector(item);
    }]toArray];
    NSArray* elementArray = [[[objArray objectEnumerator] select:^id(id item) {
        return elementSelector(item);
    }]toArray];
    return AH_AUTORELEASE([[NSMutableDictionary alloc]initWithObjects:elementArray forKeys:keyArray]);
}

-(NSData *)toData {
    NSArray * array = [self allObjects];
    NSMutableData *result = AH_AUTORELEASE([[NSMutableData alloc]initWithCapacity:[array count]]);
    for (NSNumber * obj in array) {
        char charByte = [obj charValue];
        [result appendBytes:&charByte length:1];
    }
    return result;
}

-(NSString *)toString {
    __block NSString *str = AH_AUTORELEASE([[NSString alloc]init]);
    [self forEach:^(id number) {
        unichar charShort = [(NSNumber*)number unsignedShortValue];
        [str stringByAppendingString:[NSString stringWithCharacters:&charShort length:1]];
    }];
    return str;
}

-(id)elementAt:(int)index {
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


-(id)elementOrNilAt:(int)index {
    return [[self toArray]objectAtIndex:index];
}

-(id)single {
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

-(id)single:(BOOL(^)(id))predicate {
    return [[self where:predicate]single];
}

-(id)singleOrNil {
    id item = [self nextObject];
    if (item) {
        if([self nextObject] == nil)
            return item;
        else
            [[NSException exceptionWithName:NSInvalidArgumentException
                                     reason:@"Result returned -1.."
                                   userInfo:nil]
             raise];
    }
    return nil;
}
-(id)singleOrNil:(BOOL(^)(id))predicate {
    return [[self where:predicate]singleOrNil];
}

-(id)first {
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

-(id)first:(BOOL(^)(id))predicate {
    return [[self where:predicate]first];
}


-(id)firstOrNil {
    return [self nextObject];
}

-(id)firstOrNil:(BOOL(^)(id))predicate {
    return [[self where:predicate]firstOrNil];
}


-(id)last {
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

-(id)last:(BOOL(^)(id))predicate {
    return [[self where:predicate]last];
}


-(id)lastOrNil {
    return [[self toArray]lastObject];
}

-(id)lastOrNil:(BOOL(^)(id))predicate {
    return [[self where:predicate]lastOrNil];
}


-(int)count {
    return [self toArray].count;
}


-(BOOL)all:(BOOL(^)(id))predicate {
    id item;
    while ((item = [self nextObject])) {
        if(!predicate(item))
            return NO;
    }
    return YES;
}


-(BOOL)any:(BOOL(^)(id))predicate {
    id item;
    while ((item = [self nextObject])) {
        if(predicate(item))
            return YES;
    }
    return NO;
}


-(BOOL)contains:(id)item {
    id dst;
    while ((dst = [self nextObject])) {
        if([dst isEqual:(item)])
            return YES;
    }
    return NO;
}


-(BOOL)sequenceEqual:(NSEnumerator *)dst {
    NSArray *srcArray = [self toArray];
    NSArray *dstArray = [dst toArray];
    return [srcArray isEqualToArray:dstArray];
}


-(void)forEach:(void(^)(id))action {
    for (id value in self) {
        action(value);
    }
}

-(void)forEachWithIndex:(void(^)(id,int))action {
    int counter = 0;
    for (id value in self) {
        action(value, counter++);
    }
}
#endif

@end