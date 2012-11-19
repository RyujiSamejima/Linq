#Welcome Linq for Objective-C

Objective-CにLinqの各種メソッドを導入します。

各種メソッドはNSEnumeratorのカテゴリとして実装され、処理自体は.net Frameworkの場合と同様に遅延実行されます。

##使用方法

NSEnumerator+Query.hをインポートして下さい。
NSEnumeratorに各種メソッドが追加されるので操作したいNSArrayやNSDictionaryからobjectEnumeratorによってNSEnumeratorを取得してから操作して下さい。

例）whereによって絞り込みを行う
```
NSEnumerator *list = [[someArray objectEnumerator]where^BOOL(id item) {
       return (true/* ここに条件を記載 */);}];
```

絞り込んだリストは列挙される際にフィルタ適用されます。（遅延実行）

toArrayやforEachといったメソッドで即時実行させる事も可能です。

例）otherArrayに含まれないsomeArrayの要素でディレクトリを作成する。
```
   [[[someArray objectEnumerator] where:^BOOL(id item) {
       return !([otherArray containsObject:item]);
   }] forEach:^(id item) {
       [self makeDir:item];
   }];
```

いくつかのメソッドはiOSに合う形に変更、追加してあります。
例）ToMutableArray, fromNSDataなど。詳しくはドキュメントをご覧ください。

##実装済みメソッド
###生成系
fromNSData:(NSData*)data;<br>
range:(int)start to:(int)count;<br>
repeat:(id)item count:(int)count;<br>
empty;<br>

###変換系
ofClass: (Class) class;<br>
select: (id(^)(id)) selector;<br>
selectWithIndex: (id(^)(id,int)) selector;<br>
where: (BOOL(^)(id)) predicate;<br>
whereWithIndex: (BOOL(^)(id,int)) predicate;<br>
skip: (int) count;<br>
skipWhile: (BOOL(^)(id)) predicate;<br>
skipWhileWithIndex: (BOOL(^)(id,int)) predicate;<br>
take: (int) count;<br>
takeWhile: (BOOL(^)(id)) predicate;<br>
takeWhileWithIndex: (BOOL(^)(id,int)) predicate;<br>
orderByDescription:(NSSortDescriptor *)firstObj, ... NS_REQUIRES_NIL_TERMINATION;<br>
selectMany: (id(^)(id)) selector;<br>
distinct;<br>
concat:(NSEnumerator *)dst;<br>
union:(NSEnumerator *)dst;<br>
intersect:(NSEnumerator *)dst;<br>
except:(NSEnumerator *)dst;<br>
buffer:(int)count;<br>
toArray;<br>
toMutableArray;<br>
toDictionary: (id(^)(id)) keySelector;<br>
toDictionary: (id(^)(id)) keySelector elementSelector:(id(^)(id)) elementSelector;<br>
toMutableDictionary: (id(^)(id)) keySelector;<br>
toMutableDictionary: (id(^)(id)) keySelector elementSelector:(id(^)(id)) elementSelector;<br>
toNSData;<br>

###要素取得系
elementAt:(int)index;<br>
elementOrNilAt:(int)index;<br>
single;<br>
single:(BOOL(^)(id)) predicate;<br>
singleOrNil;<br>
singleOrNil:(BOOL(^)(id)) predicate;<br>
first;<br>
first:(BOOL(^)(id)) predicate;<br>
firstOrNil;<br>
firstOrNil:(BOOL(^)(id)) predicate;<br>
last;<br>
last:(BOOL(^)(id)) predicate;<br>
lastOrNil;<br>
lastOrNil:(BOOL(^)(id)) predicate;<br>

###集計系
count;<br>
all: (BOOL(^)(id)) predicate;<br>
any: (BOOL(^)(id)) predicate;<br>
contains : (id) item;<br>
sequenceEqual: (NSEnumerator *)dst;<br>

###処理関数系
forEach: (void(^)(id item)) action;<br>


====