#Welcome Linq for Objective-C

Objective-CにLinqの各種メソッドを導入します。

各種メソッドはNSEnumeratorのカテゴリとして実装され、処理自体は.net Frameworkの場合と同様に遅延実行されます。

##[Linq to Xml](/LinqToXml.md/)
.net frameworkのXDocument等のLinq to XmlでのXmlツリー表現をまねた物を実装しました。Xmlに対してLinqを行う事が出来ます。
詳細は[Linq to Xml](/LinqToXml.md/)のドキュメントをご確認ください。

##メソッドチェイン記法
ブロックを返すプロパティでの実装を追加しました。いわゆるメソッドチェインでの記述が可能になります。
例）otherArrayに含まれないsomeArrayの要素でディレクトリを作成する。
```
    someArray.getEnumerator()
    .where(^BOOL(id item) {
        return !(otherArray.contains(item));
    }).forEach(^(id item) {
       [self makeDir:item];
    });
```
※本変更にともない幾つかのメソッド名が変更となる等破壊的な変更となっています。旧方式での実装も残してあるため#defineにて切り替えください。
USE_METHOD_CHAINを有効にする事でメソッドチェインバージョン。C#と記法が近くなる代わりにxCodeでの入力支援が有効に働かないようです。

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
例）toMutableArray, fromNSDataなど。詳しくはドキュメントをご覧ください。

##実装済みメソッド
###生成系
range:(int)start to:(int)count;<br>
repeat:(id)item count:(int)count;<br>
empty;<br>

##以下メソッドバージョン
###変換系
ofClass:(Class) class;<br>
select:(id(^)(id)) selector;<br>
selectWithIndex:(id(^)(id,int)) selector;<br>
where:(BOOL(^)(id)) predicate;<br>
whereWithIndex:(BOOL(^)(id,int)) predicate;<br>
skip:(int) count;<br>
skipWhile:(BOOL(^)(id)) predicate;<br>
skipWhileWithIndex:(BOOL(^)(id,int)) predicate;<br>
take:(int) count;<br>
takeWhile:(BOOL(^)(id)) predicate;<br>
takeWhileWithIndex:(BOOL(^)(id,int)) predicate;<br>
scan:(id(^)(id,id))accumlator;<br>
orderByDescription:(NSSortDescriptor *)firstObj, ... NS_REQUIRES_NIL_TERMINATION;<br>
selectMany:(id(^)(id)) selector;<br>
distinct;<br>
concat:(NSEnumerator *)dst;<br>
unions:(NSEnumerator *)dst;<br>
intersect:(NSEnumerator *)dst;<br>
except:(NSEnumerator *)dst;<br>
buffer:(int)count;<br>
toArray;<br>
toMutableArray;<br>
toDictionary:(id(^)(id)) keySelector;<br>
toDictionary:(id(^)(id)) keySelector elementSelector:(id(^)(id)) elementSelector;<br>
toMutableDictionary:(id(^)(id)) keySelector;<br>
toMutableDictionary:(id(^)(id)) keySelector elementSelector:(id(^)(id)) elementSelector;<br>
toData;<br>
toString;<br>

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
all:(BOOL(^)(id)) predicate;<br>
any:(BOOL(^)(id)) predicate;<br>
contains:(id) item;<br>
sequenceEqual:(NSEnumerator *)dst;<br>

###処理関数系
forEach:(void(^)(id item)) action;<br>

##シーケンス生成の追加カテゴリ
###NSData
objectEnumerator<br>
###NSString
objectEnumerator<br>
<br>

##以下メソッドチェインバージョン
###変換系
ofClass(Class classType);<br>
select(id(^selector)(id item));<br>
selectWithIndex(id(^selector)(id item,int index));<br>
where(BOOL(^predicate)(id item));<br>
whereWithIndex((BOOL(^predicate)(id item,int index));<br>
skip(int count);<br>
skipWhile(BOOL(^predicate)(id item));<br>
skipWhileWithIndex(BOOL(^predicate)(id item,int index));<br>
take(int count);<br>
takeWhile(BOOL(^predicate)(id));<br>
takeWhileWithIndex(BOOL(^predicate)(id item,int index));<br>
scan(id(^accumlator)(id seed,id item));<br>
orderByDescription(NSSortDescriptor *firstObj, ...);<br>
selectMany(id(^selector)(id index));<br>
distinct();<br>
concat(NSEnumerator *dst);<br>
unions(NSEnumerator *dst);<br>
intersect(NSEnumerator *dst);<br>
except(NSEnumerator *dst);<br>
buffer(int count);<br>
toArray();<br>
toMutableArray();<br>
toDictionary(id(^keySelector)(id item));<br>
toDictionaryWithSelector(id(^keySelector)(id item), id(^elementSelector)(id item));<br>
toMutableDictionary(id(^keySelector)(id item));<br>
toMutableDictionaryWithSelector(id(^keySelector)(id), id(^elementSelector)(id item));<br>
toData();<br>
toString();<br>

###要素取得系
elementAt(int index);<br>
elementOrNilAt(int index);<br>
single();<br>
singleWithPredicate(BOOL(^predicate)(id item));<br>
singleOrNil();<br>
singleOrNilWithPredicate:(BOOL(^predicate)(id item));<br>
first();<br>
firstWithPredicate(BOOL(^predicate)(id item));<br>
firstOrNil();<br>
firstOrNilWithPredicate(BOOL(^predicate)(id item));<br>
last();<br>
lastWithPredicate(BOOL(^predicate)(id item));<br>
lastOrNil();<br>
lastOrNilWithPredicate(BOOL(^predicate)(id item));<br>

###集計系
count();<br>
all(BOOL(^predicate)(id));<br>
any(BOOL(^predicate)(id));<br>
contains(id item);<br>
sequenceEqual(NSEnumerator *dst);<br>

###処理関数系
forEach(void(^action)(id item));<br>

##シーケンス生成の追加カテゴリ
###NSData
getEnumerator();<br>
###NSString
getEnumerator();<br>
###NSArray
getEnumerator();<br>
###NSDictionary
getEnumerator();<br>
getKeyEnumerator();<br>
<br>

====