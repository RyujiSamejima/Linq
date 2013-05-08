//
//  LinqTestAppTests.m
//  LinqTestAppTests
//
//  Copyright (c) 2012年 Ryuji Samejima. All rights reserved.
//

#import "LinqTestAppTests.h"
#import "NSEnumerator+Query.h"
#import "LQXDocument.h"

@implementation LinqTestAppTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

//メソッドチェインバージョン
#ifdef USE_METHOD_CHAIN

-(void) testOfClass
{
    NSArray *mixed = [NSArray arrayWithObjects:@"C#", @"Java", [NSNumber numberWithDouble:3.141592653], @"Groovy", @"Scala", nil];
    NSEnumerator *enumerator = mixed.getEnumerator().ofClass([NSString class]);
    
    STAssertEquals([enumerator nextObject], @"C#", @"期待要素と違います" );
    STAssertEquals([enumerator nextObject], @"Java", @"期待要素と違います" );
    STAssertEquals([enumerator nextObject], @"Groovy", @"期待要素と違います" );
    STAssertEquals([enumerator nextObject], @"Scala", @"期待要素と違います" );
}

- (void)testGet
{
    NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInt:11]
                     , [NSNumber numberWithInt:16]
                     , [NSNumber numberWithInt:52]
                     , [NSNumber numberWithInt:21]
                     , [NSNumber numberWithInt:8]
                     , [NSNumber numberWithInt:8]
                     , nil];
    
    NSEnumerator *source = [data objectEnumerator];
    STAssertEquals([source.elementAt(2) intValue], 52, @"期待要素と違います" );
    
    source = data.getEnumerator();//イテレータを再取得（挙動を合わせるためこうしておく）
    STAssertEquals([source.first() intValue], 11, @"期待要素と違います" );
    
    source = data.getEnumerator();
    STAssertEquals([source.firstWithPredicate(^BOOL(id e) { return ([e intValue] > 15); }) intValue], 16, @"期待要素と違います" );
    
    source = data.getEnumerator();
    STAssertEquals([source.last() intValue], 8, @"期待要素と違います" );
    
    source = data.getEnumerator();
    STAssertEquals([source.lastWithPredicate(^BOOL(id e) { return ([e intValue] > 15); }) intValue], 21, @"期待要素と違います" );
    
    source = data.getEnumerator();
    STAssertEquals([source.singleWithPredicate(^BOOL(id e) { return ([e intValue] > 50); }) intValue], 52, @"期待要素と違います" );
    
    source = data.getEnumerator().where(^BOOL(id e) { return ([e intValue]> 20); });
    STAssertEquals([[source nextObject]intValue], 52, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 21, @"期待要素と違います" );
    
    source = data.getEnumerator().distinct();
    STAssertEquals([[source nextObject]intValue], 11, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 16, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 52, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 21, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 8, @"期待要素と違います" );
    
    source = data.getEnumerator().skip(3);
    STAssertEquals([[source nextObject]intValue], 21, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 8, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 8, @"期待要素と違います" );
    
    source = data.getEnumerator().skipWhile(^BOOL(id e) { return ([e intValue] < 20); });
    STAssertEquals([[source nextObject]intValue], 52, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 21, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 8, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 8, @"期待要素と違います" );
    
    source = data.getEnumerator().take(3);
    STAssertEquals([[source nextObject]intValue], 11, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 16, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 52, @"期待要素と違います" );
    
    source = data.getEnumerator().takeWhile(^BOOL(id e) { return ([e intValue] < 20); });
    STAssertEquals([[source nextObject]intValue], 11, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 16, @"期待要素と違います" );
    
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"intValue" ascending:YES];
    source = data.getEnumerator().orderByDescription(desc, nil);
    
    STAssertEquals([[source nextObject]intValue], 8, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 8, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 11, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 16, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 21, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 52, @"期待要素と違います" );
    
}

- (void)testPredicate
{
    NSArray *firstData = [NSArray arrayWithObjects:[NSNumber numberWithInt:11]
                          , [NSNumber numberWithInt:16]
                          , [NSNumber numberWithInt:52]
                          , [NSNumber numberWithInt:21]
                          , [NSNumber numberWithInt:8]
                          , [NSNumber numberWithInt:8]
                          , nil];
    NSArray *secondData = [NSArray arrayWithObjects:[NSNumber numberWithInt:11]
                           , [NSNumber numberWithInt:16]
                           , [NSNumber numberWithInt:21]
                           , [NSNumber numberWithInt:52]
                           , [NSNumber numberWithInt:8]
                           , [NSNumber numberWithInt:8]
                           , nil];
    
    NSEnumerator *source = firstData.getEnumerator();
    STAssertEquals(source.all(^BOOL(id e) { return ([e intValue] > 10); }), NO, @"期待要素と違います" );
    source = firstData.getEnumerator();
    STAssertEquals(source.any(^BOOL(id e) { return ([e intValue] > 10); }), YES, @"期待要素と違います" );
    source = firstData.getEnumerator();
    STAssertEquals(source.contains([NSNumber numberWithInt:20]), NO, @"期待要素と違います" );
    source = firstData.getEnumerator();
    STAssertEquals(source.all(^BOOL(id e) { return ([e intValue] > 10); }), NO, @"期待要素と違います" );
    source = firstData.getEnumerator();
    STAssertEquals(source.sequenceEqual(secondData.getEnumerator()), NO, @"期待要素と違います" );
    source = firstData.getEnumerator();
    STAssertEquals(source.sequenceEqual(firstData.getEnumerator()), YES, @"期待要素と違います" );
    // -> False
}

- (void)testGroup
{
    
    NSArray *firstData = [NSArray arrayWithObjects:[NSNumber numberWithInt:11]
                          , [NSNumber numberWithInt:16]
                          , [NSNumber numberWithInt:52]
                          , [NSNumber numberWithInt:21]
                          , [NSNumber numberWithInt:8]
                          , [NSNumber numberWithInt:8]
                          ,nil];
    NSArray *secondData = [NSArray arrayWithObjects:[NSNumber numberWithInt:16]
                           , [NSNumber numberWithInt:21]
                           , [NSNumber numberWithInt:20]
                           , [NSNumber numberWithInt:3]
                           ,nil];
    
    NSEnumerator *first = firstData.getEnumerator();
    NSEnumerator *second = secondData.getEnumerator();
    NSEnumerator *enumerator = first.concat(second);
    STAssertEquals([[enumerator nextObject]intValue], 11, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 16, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 52, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 21, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 8, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 8, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 16, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 21, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 20, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 3, @"期待要素と違います" );
    
    first = firstData.getEnumerator();
    second = secondData.getEnumerator();
    enumerator = first.except(second);
    STAssertEquals([[enumerator nextObject]intValue], 11, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 52, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 8, @"期待要素と違います" );
    
    first = firstData.getEnumerator();
    second = secondData.getEnumerator();
    enumerator = first.intersect(second);
    STAssertEquals([[enumerator nextObject]intValue], 16, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 21, @"期待要素と違います" );
    
    first = firstData.getEnumerator();
    second = secondData.getEnumerator();
    enumerator = first.unions(second);
    STAssertEquals([[enumerator nextObject]intValue], 11, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 16, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 52, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 21, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 8, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 20, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 3, @"期待要素と違います" );
    
}

#else

-(void) testOfClass
{
    NSArray *mixed = [NSArray arrayWithObjects:@"C#", @"Java", [NSNumber numberWithDouble:3.141592653], @"Groovy", @"Scala", nil];
    NSEnumerator *enumerator = [[mixed objectEnumerator]ofClass:[NSString class]];
    
    STAssertEquals([enumerator nextObject], @"C#", @"期待要素と違います" );
    STAssertEquals([enumerator nextObject], @"Java", @"期待要素と違います" );
    STAssertEquals([enumerator nextObject], @"Groovy", @"期待要素と違います" );
    STAssertEquals([enumerator nextObject], @"Scala", @"期待要素と違います" );
}

- (void)testGet
{
    NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInt:11]
                     , [NSNumber numberWithInt:16]
                     , [NSNumber numberWithInt:52]
                     , [NSNumber numberWithInt:21]
                     , [NSNumber numberWithInt:8]
                     , [NSNumber numberWithInt:8]
                     , nil];
    
    NSEnumerator *source = [data objectEnumerator];
    STAssertEquals([[source elementAt:2]intValue], 52, @"期待要素と違います" );
    
    source = [data objectEnumerator];//イテレータを再取得（挙動を合わせるためこうしておく）
    STAssertEquals([[source first]intValue], 11, @"期待要素と違います" );
    
    source = [data objectEnumerator];
    STAssertEquals([[source first:^BOOL(id e) { return ([e intValue] > 15); }]intValue], 16, @"期待要素と違います" );
    
    source = [data objectEnumerator];
    STAssertEquals([[source last]intValue], 8, @"期待要素と違います" );
    
    source = [data objectEnumerator];
    STAssertEquals([[source last:^BOOL(id e) { return ([e intValue] > 15); }]intValue], 21, @"期待要素と違います" );
    
    source = [data objectEnumerator];
    STAssertEquals([[source single:^BOOL(id e) { return ([e intValue] > 50); }]intValue], 52, @"期待要素と違います" );
    
    source = [[data objectEnumerator]where:^BOOL(id e) { return ([e intValue]> 20); }];
    STAssertEquals([[source nextObject]intValue], 52, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 21, @"期待要素と違います" );
    
    source = [[data objectEnumerator]distinct];
    STAssertEquals([[source nextObject]intValue], 11, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 16, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 52, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 21, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 8, @"期待要素と違います" );
    
    source = [[data objectEnumerator]skip:3];
    STAssertEquals([[source nextObject]intValue], 21, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 8, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 8, @"期待要素と違います" );
    
    source = [[data objectEnumerator]skipWhile:^BOOL(id e) { return ([e intValue] < 20); }];
    STAssertEquals([[source nextObject]intValue], 52, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 21, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 8, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 8, @"期待要素と違います" );
    
    source = [[data objectEnumerator]take:3];
    STAssertEquals([[source nextObject]intValue], 11, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 16, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 52, @"期待要素と違います" );
    
    source = [[data objectEnumerator]takeWhile:^BOOL(id e) { return ([e intValue] < 20); }];
    STAssertEquals([[source nextObject]intValue], 11, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 16, @"期待要素と違います" );
    
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"intValue" ascending:YES];
    source = [[data objectEnumerator]orderByDescription:desc, nil ];
    
    STAssertEquals([[source nextObject]intValue], 8, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 8, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 11, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 16, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 21, @"期待要素と違います" );
    STAssertEquals([[source nextObject]intValue], 52, @"期待要素と違います" );
    
}

- (void)testPredicate
{
    NSArray *firstData = [NSArray arrayWithObjects:[NSNumber numberWithInt:11]
                          , [NSNumber numberWithInt:16]
                          , [NSNumber numberWithInt:52]
                          , [NSNumber numberWithInt:21]
                          , [NSNumber numberWithInt:8]
                          , [NSNumber numberWithInt:8]
                          , nil];
    NSArray *secondData = [NSArray arrayWithObjects:[NSNumber numberWithInt:11]
                           , [NSNumber numberWithInt:16]
                           , [NSNumber numberWithInt:21]
                           , [NSNumber numberWithInt:52]
                           , [NSNumber numberWithInt:8]
                           , [NSNumber numberWithInt:8]
                           , nil];
    
    NSEnumerator *source = [firstData objectEnumerator];
    STAssertEquals([source all:^BOOL(id e) { return ([e intValue] > 10); }], NO, @"期待要素と違います" );
    source = [firstData objectEnumerator];
    STAssertEquals([source any:^BOOL(id e) { return ([e intValue] > 10); }], YES, @"期待要素と違います" );
    source = [firstData objectEnumerator];
    STAssertEquals([source contains:[NSNumber numberWithInt:20]], NO, @"期待要素と違います" );
    source = [firstData objectEnumerator];
    STAssertEquals([source all:^BOOL(id e) { return ([e intValue] > 10); }], NO, @"期待要素と違います" );
    source = [firstData objectEnumerator];
    STAssertEquals([source sequenceEqual:[secondData objectEnumerator]], NO, @"期待要素と違います" );
    source = [firstData objectEnumerator];
    STAssertEquals([source sequenceEqual:[firstData objectEnumerator]], YES, @"期待要素と違います" );
    // -> False
}

- (void)testGroup
{
    
    NSArray *firstData = [NSArray arrayWithObjects:[NSNumber numberWithInt:11]
                          , [NSNumber numberWithInt:16]
                          , [NSNumber numberWithInt:52]
                          , [NSNumber numberWithInt:21]
                          , [NSNumber numberWithInt:8]
                          , [NSNumber numberWithInt:8]
                          ,nil];
    NSArray *secondData = [NSArray arrayWithObjects:[NSNumber numberWithInt:16]
                           , [NSNumber numberWithInt:21]
                           , [NSNumber numberWithInt:20]
                           , [NSNumber numberWithInt:3]
                           ,nil];
    
    NSEnumerator *first = [firstData objectEnumerator];
    NSEnumerator *second = [secondData objectEnumerator];
    NSEnumerator *enumerator = [first concat:second];
    STAssertEquals([[enumerator nextObject]intValue], 11, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 16, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 52, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 21, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 8, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 8, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 16, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 21, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 20, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 3, @"期待要素と違います" );
    
    first = [firstData objectEnumerator];
    second = [secondData objectEnumerator];
    enumerator = [first except:second];
    STAssertEquals([[enumerator nextObject]intValue], 11, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 52, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 8, @"期待要素と違います" );
    
    first = [firstData objectEnumerator];
    second = [secondData objectEnumerator];
    enumerator = [first intersect:second];
    STAssertEquals([[enumerator nextObject]intValue], 16, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 21, @"期待要素と違います" );
    
    first = [firstData objectEnumerator];
    second = [secondData objectEnumerator];
    enumerator = [first unions:second];
    STAssertEquals([[enumerator nextObject]intValue], 11, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 16, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 52, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 21, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 8, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 20, @"期待要素と違います" );
    STAssertEquals([[enumerator nextObject]intValue], 3, @"期待要素と違います" );
    
}
#endif

- (void)testXml
{
    LQXDocument *document = [LQXDocument documentWithDeclaration:[LQXDeclaration declareWithEncoding:NSUTF8StringEncoding version:@"1.0"] objects:
                             [LQXElement element:@"Child" objects:
                              [LQXElement element:@"Child1" value:@"1"],
                              [LQXElement element:@"Child2" value:@"2"],
                              [LQXElement element:@"Child3" value:@"3"],
                              [LQXElement element:@"Child4" value:@"4"],
                              [LQXElement element:@"Child5" value:@"5"],nil],nil];
    NSLog(@"%@",document);
    
    NSString *nameSpace = @"http://www.adventure-works.com";
    LQXElement *element = [LQXElement elementWithXName:[LQXName nameSpace:nameSpace localName:@"Root"] objects:
                              [LQXElement elementWithXName:[LQXName nameSpace:nameSpace localName:@"Child1"] value:@"1"],
                              [LQXElement element:@"{http://www.adventure-works.com}Child2" value:@"2"],
                              [LQXElement element:@"{http://www.adventure-works2.com}Child3" value:@"3"],
                              [LQXElement element:@"{http://www.adventure-works3.com}Child4" value:@"4"],
                              [LQXElement element:@"Child5" value:@"5"],nil];
    NSLog(@"%@",element);
    
    document = [LQXDocument load:@"hoken_dsaisyu_tokutei"];
    NSLog(@"%@",document);
    element = [LQXElement load:@"hoken_dsaisyu_tokutei"];
    NSLog(@"%@",element);
}
@end
