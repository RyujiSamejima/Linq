#Welcome Linq for Objective-C

Objective-CにLinqの各種メソッドを導入します。

各種メソッドはNSEnumeratorのカテゴリとして実装され、処理自体は.net Frameworkの場合と同様に遅延実行されます。

現状は一部メソッドのみの実装となっています。（追加予定）

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
====