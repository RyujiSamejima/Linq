//
//  NSEnumerator+Query.h
//

//従来のメソッドバージョンを使用する場合は下記defineをコメントに
#define USE_METHOD_CHAIN

/*!
 @header      NSEnumerator+Query.h
 @abstract    カスタム列挙子
 */

#import <Foundation/Foundation.h>

/*!
 @abstract    カスタム列挙子クラス
 */
@interface CustomEnumerator : NSEnumerator
{
    /*! データ取得元 */
    NSEnumerator *_src;
    /*! 次の要素を取得する処理block */
    id (^_nextObject)(NSEnumerator *);
}

/*!
 @abstract      CustomEnumeratorを作成する。
 @discussion    nextObjectの実行ブロックで初期化する。
 @param         src データ取得元
 @param         nextObject 次の要素を返却する処理ブロック
 @result        初期化されたCustomEnumerator
*/
- (id)initWithFunction:(NSEnumerator *)src nextObjectBlock:(id(^)(NSEnumerator *))nextObject;

/*!
 @abstract      次の要素を取得する。
 @result        次の要素 
 */
- (id)nextObject;

@end

//メソッドチェインバージョン
#ifdef USE_METHOD_CHAIN

/*!
 @abstract      リスト処理用カテゴリ
 @discussion    リストに対して様々な処理を提供する
 */
@interface NSData (Query)

/*!
 @abstract      列挙子を作成する。
 @discussion    NSData１バイト毎のchar配列の列挙子で初期化する。
 @result        作成されたEnumerator
 */
@property (readonly) NSEnumerator *(^getEnumerator)();

@end

/*!
 @abstract      リスト処理用カテゴリ
 @discussion    リストに対して様々な処理を提供する
 */
@interface NSString (Query)

/*!
 @abstract      列挙子を作成する。
 @discussion    １文字毎のunichar配列の列挙子で初期化する。
 @result        作成されたEnumerator
 */
@property (readonly) NSEnumerator *(^getEnumerator)();

@end

@interface NSArray (Query)

/*!
 @abstract      列挙子を作成する。
 @result        作成されたEnumerator
 */
@property (readonly) NSEnumerator *(^getEnumerator)();

@end

@interface NSDictionary (Query)

/*!
 @abstract      要素の列挙子を作成する。
 @result        作成されたEnumerator
 */
@property (readonly) NSEnumerator *(^getEnumerator)();
/*!
 @abstract      キーの列挙子を作成する。
 @result        作成されたEnumerator
 */
@property (readonly) NSEnumerator *(^getKeyEnumerator)();

@end

/*!
 @abstract      リスト処理用カテゴリ
 @discussion    リストに対して様々な処理を提供する
 */
@interface NSEnumerator (Query)


#pragma mark - 生成系

/*!
 @abstract      数値リストの列挙子を作成する
 @discussion    startからcount分のリストを作成する
 @param         start 開始
 @param         count 数
 @result        作成されたEnumerator
 */
+(NSEnumerator *)range:(int)start to:(int)count;

/*!
 @abstract      要素を繰り返す列挙子を作成する。
 @discussion    指定要素をcount分繰り返すリストを作成する
 @param         item 繰り返す対象
 @param         count 数
 @result        作成されたEnumerator
 */
+(NSEnumerator *)repeat:(id)item count:(int)count;

/*!
 @abstract      空の列挙子を作成する
 @discussion    空の列挙子を作成する
 @result        作成されたEnumerator
 */
+(NSEnumerator *)empty;

#pragma mark - 変換系
/*!
 @abstract      指定したクラスの物のみ取得する
 */
@property (readonly) NSEnumerator *(^ofClass)(Class classType);

/*!
 @abstract      リストを変換する
 */
@property (readonly) NSEnumerator *(^select)(id(^selector)(id item));

/*!
 @abstract      リストを変換する
 @discussion    リストを変換する(index付)
 */
@property (readonly) NSEnumerator *(^selectWithIndex)(id(^selector)(id item,int index));

/*!
 @abstract      条件に一致するもののみ取得する
 */
@property (readonly) NSEnumerator *(^where)(BOOL(^predicate)(id item));

/*!
 @abstract      条件に一致するもののみ取得する
 @discussion    条件に一致するもののみ取得する(index付)
 */
@property (readonly) NSEnumerator *(^whereWithIndex)(BOOL(^predicate)(id item,int index));

/*!
 @abstract      指定された数だけ読み飛ばす
 */
@property (readonly) NSEnumerator *(^skip)(int count);

/*!
 @abstract      条件に一致する間は読み飛ばす
 */
@property (readonly) NSEnumerator *(^skipWhile)(BOOL(^predicate)(id item));

/*!
 @abstract      条件に一致する間は読み飛ばす
 @discussion    条件に一致する間は読み飛ばす(index付)
 */
@property (readonly) NSEnumerator *(^skipWhileWithIndex)(BOOL(^predicate)(id item,int index));

/*!
 @abstract      指定された数だけ取得する
 */
@property (readonly) NSEnumerator *(^take)(int count);

/*!
 @abstract      条件に一致する間は取得する
 */
@property (readonly) NSEnumerator *(^takeWhile)(BOOL(^predicate)(id item));

/*!
 @abstract      条件に一致する間は取得する
 @discussion    条件に一致する間は取得する(index付)
 @result        フィルタ後のリスト
 */
@property (readonly) NSEnumerator *(^takeWhileWithIndex)(BOOL(^predicate)(id item,int index));

/*!
 @abstract      リストに関数適用を行い途中結果を列挙する
 @discussion    リストに関数適用を行い途中結果を列挙する
 @result        結果リスト
 */
@property (readonly) NSEnumerator *(^scan)(id(^accumlator)(id seed,id item));

/*!
 @abstract      ソートする
 @discussion    ソート条件はnil終端すること
 @result        フィルタ後のリスト
 */
@property (readonly) NSEnumerator *(^orderByDescription)(NSSortDescriptor *firstObj, ...);

/*!
 @abstract      リストからなるリストを展開する
 @result        展開後のリスト
 */
@property (readonly) NSEnumerator *(^selectMany)(id(^selector)(id item));

/*!
 @abstract      リストを重複を除外して連結する
 @result        連結後のリスト
 */
@property (readonly) NSEnumerator *(^distinct)();

/*!
 @abstract      リストを連結する
 @result        連結後のリスト
 */
@property (readonly) NSEnumerator *(^concat)(NSEnumerator *dst);

/*!
 @abstract      リストを重複を除外して連結する
 @result        連結後のリスト
 */
@property (readonly) NSEnumerator *(^unions)(NSEnumerator *dst);

/*!
 @abstract      積集合を取得します
 @discussion    シーケンスの両方に存在している要素のみが抽出されます
 @result        積集合のリスト
 */
@property (readonly) NSEnumerator *(^intersect)(NSEnumerator *dst);

/*!
 @abstract      差集合を取得します
 @discussion    シーケンスの片方だけに存在している要素のみが抽出されます
 @result        差集合のリスト
 */
@property (readonly) NSEnumerator *(^except)(NSEnumerator *dst);

/*!
 @abstract      指定個数に区切った配列で取得します
 @discussion    要素を指定個数ずつのNSArrayとして取得します。
 @result        count毎に区切られた要素
 */
@property (readonly) NSEnumerator *(^buffer)(int count);


/*!
 @abstract      NSArrayに変換する
 @result        変換したNSArray
 */
@property (readonly) NSArray *(^toArray)();

/*!
 @abstract      NSMutableArrayに変換する
 @result        変換したNSMutableArray
 */
@property (readonly) NSMutableArray *(^toMutableArray)();

/*!
 @abstract      NSDictionaryに変換する
 @result        変換したNSDictionary
 */
@property (readonly) NSDictionary *(^toDictionary)(id(^keySelector)(id item));

/*!
 @abstract      NSDictionaryに変換する
 @result        変換したNSDictionary
 */
@property (readonly) NSDictionary *(^toDictionaryWithSelector)(id(^keySelector)(id item), id(^elementSelector)(id item)) ;

/*!
 @abstract      NSMutableDictionaryに変換する
 @result        変換したNSMutableDictionary
 */
@property (readonly) NSMutableDictionary *(^toMutableDictionary)(id(^keySelector)(id item)) ;

/*!
 @abstract      NSMutableDictionaryに変換する
 @result        変換したNSMutableDictionary
 */
@property (readonly) NSMutableDictionary *(^toMutableDictionaryWithSelector)(id(^keySelector)(id item), id(^elementSelector)(id item)) ;


/*!
 @abstract      charからなる配列をNSDataに変換する
 @result        変換したNSData
 */
@property (readonly) NSData *(^toData)();

/*!
 @abstract      unicharからなる配列をNSStringに変換する
 @result        変換したNSData
 */
@property (readonly) NSString *(^toString)();

#pragma mark - 要素取得系

/*!
 @abstract      指定位置の要素を取得する
 @discussion    要素が無い場合には例外を返す。
 @exception     NSInvalidArgumentException   要素がない場合
 @result        フィルタ後のリスト
 */
@property (readonly) id(^elementAt)(int index);

/*!
 @abstract      指定位置の要素を取得する
 @discussion    要素が無い場合にnilを返す。
 @result        フィルタ後のリスト
 */
@property (readonly) id(^elementOrNilAt)(int index);

/*!
 @abstract      単一要素に変換する
 @discussion    要素が無い場合には例外を返す。
 @exception     NSInvalidArgumentException   要素がない、複数件数ある場合
 @result        フィルタ後のリスト
 */
@property (readonly) id(^single)();

/*!
 @abstract      単一要素に変換する
 @discussion    要素が無い場合には例外を返す。
 @exception     NSInvalidArgumentException   要素がない、複数件数ある場合
 @result        フィルタ後のリスト
 */
@property (readonly) id(^singleWithPredicate)(BOOL(^predicate)(id item));

/*!
 @abstract      単一要素に変換する
 @discussion    要素が無い場合にnilを返す。
 @exception     NSInvalidArgumentException   複数件数ある場合
 @result        フィルタ後のリスト
 */
@property (readonly) id(^singleOrNil)();

/*!
 @abstract      単一要素に変換する
 @discussion    要素が無い場合にnilを返す。
 @exception     NSInvalidArgumentException   複数件数ある場合
 @result        フィルタ後のリスト
 */
@property (readonly) id(^singleOrNilWithPredicate)(BOOL(^predicate)(id item));



/*!
 @abstract      先頭要素のみ取得する
 @discussion    要素が無い場合には例外を返す。
 @exception     NSInvalidArgumentException   要素がない場合
 @result        フィルタ後のリスト
 */
@property (readonly) id(^first)();

/*!
 @abstract      先頭要素のみ取得する
 @discussion    要素が無い場合には例外を返す。
 @exception     NSInvalidArgumentException   要素がない場合
 @result        フィルタ後のリスト
 */
@property (readonly) id(^firstWithPredicate)(BOOL(^predicate)(id item));


/*!
 @abstract      先頭要素のみ取得する
 @discussion    要素が無い場合にnilを返す。
 @result        フィルタ後のリスト
 */
@property (readonly) id(^firstOrNil)();

/*!
 @abstract      先頭要素のみ取得する
 @discussion    要素が無い場合にnilを返す。
 @result        フィルタ後のリスト
 */
@property (readonly) id(^firstOrNilWithPredicate)(BOOL(^predicate)(id item));


/*!
 @abstract      最終要素のみ取得する
 @discussion    要素が無い場合には例外を返す。
 @exception     NSInvalidArgumentException   要素がない場合
 @result        フィルタ後のリスト
 */
@property (readonly) id(^last)();

/*!
 @abstract      最終要素のみ取得する
 @discussion    要素が無い場合には例外を返す。
 @exception     NSInvalidArgumentException   要素がない場合
 @result        フィルタ後のリスト
 */
@property (readonly) id(^lastWithPredicate)(BOOL(^predicate)(id item));

/*!
 @abstract      最終要素のみ取得する
 @discussion    要素が無い場合にnilを返す。
 @result        フィルタ後のリスト
 */
@property (readonly) id(^lastOrNil)();

/*!
 @abstract      最終要素のみ取得する
 @discussion    要素が無い場合にnilを返す。
 @result        フィルタ後のリスト
 */
@property (readonly) id(^lastOrNilWithPredicate)(BOOL(^predicate)(id item));

/*!
 @abstract      件数を取得する
 @result        件数
 */
@property (readonly) int(^count)();

/*!
 @abstract      シーケンスの要素がすべて条件を満たすか調べる
 @result        条件を満たす場合:YES 満たさない場合:NO
 */
@property (readonly) BOOL(^all)(BOOL(^predicate)(id item));

/*!
 @abstract      シーケンスに条件を満たす要素が含まれるか調べる
 @result        条件を満たす要素が含まれる場合:YES 含まれない場合:NO
 */
@property (readonly) BOOL(^any)(BOOL(^predicate)(id item));

/*!
 @abstract      シーケンスに要素が含まれているか調べる
 @result        検証する要素が含まれる場合:YES 含まれない場合:NO
 */
@property (readonly) BOOL(^contains)(id item);

/*!
 @abstract      シーケンスが一致するか調べる
 @result        シーケンスが一致場合:YES 一致しない場合:NO
 */
@property (readonly) BOOL(^sequenceEqual)(NSEnumerator *dst);

#pragma mark - 処理関数系

/*!
 @abstract      リストに処理を適用する
 */
@property (readonly) void(^forEach)(void(^action)(id item));

//従来のメソッドバージョン
#else

/*!
 @abstract      リスト処理用カテゴリ
 @discussion    リストに対して様々な処理を提供する
 */
@interface NSData (Query)

/*!
 @abstract      列挙子を作成する。
 @discussion    NSData１バイト毎のchar配列の列挙子で初期化する。
 @result        作成されたEnumerator
 */
-(NSEnumerator *)objectEnumerator;

@end

/*!
 @abstract      リスト処理用カテゴリ
 @discussion    リストに対して様々な処理を提供する
 */
@interface NSString (Query)

/*!
 @abstract      列挙子を作成する。
 @discussion    １文字毎のunichar配列の列挙子で初期化する。
 @result        作成されたEnumerator
 */
-(NSEnumerator *)objectEnumerator;

@end

/*!
 @abstract      リスト処理用カテゴリ
 @discussion    リストに対して様々な処理を提供する
 */
@interface NSEnumerator (Query)


#pragma mark - 生成系

/*!
 @abstract      数値リストの列挙子を作成する
 @discussion    startからcount分のリストを作成する
 @param         start 開始
 @param         count 数
 @result        作成されたEnumerator
 */
+(NSEnumerator *)range:(int)start to:(int)count;

/*!
 @abstract      要素を繰り返す列挙子を作成する。
 @discussion    指定要素をcount分繰り返すリストを作成する
 @param         item 繰り返す対象
 @param         count 数
 @result        作成されたEnumerator
 */
+(NSEnumerator *)repeat:(id)item count:(int)count;

/*!
 @abstract      空の列挙子を作成する
 @discussion    空の列挙子を作成する
 @result        作成されたEnumerator
 */
+(NSEnumerator *)empty;

#pragma mark - 変換系
/*!
 @abstract      指定したクラスの物のみ取得する
 @param         classType 取得対象クラス
 @result        フィルタ後のリスト
 */
- (NSEnumerator *) ofClass: (Class) classType;

/*!
 @abstract      リストを変換する
 @param         selector 変換関数
 @result        フィルタ後のリスト
 */
-(NSEnumerator *) select: (id(^)(id)) selector;

/*!
 @abstract      リストを変換する
 @discussion    リストを変換する(index付)
 @param         selector 変換関数
 @result        フィルタ後のリスト
 */
-(NSEnumerator *) selectWithIndex: (id(^)(id,int)) selector;

/*!
 @abstract      条件に一致するもののみ取得する
 @param         predicate 判定関数
 @result        フィルタ後のリスト
 */
-(NSEnumerator *) where: (BOOL(^)(id)) predicate;

/*!
 @abstract      条件に一致するもののみ取得する
 @discussion    条件に一致するもののみ取得する(index付)
 @param         predicate 判定関数
 @result        フィルタ後のリスト
 */
-(NSEnumerator *) whereWithIndex: (BOOL(^)(id,int)) predicate;

/*!
 @abstract      指定された数だけ読み飛ばす
 @param         count 読み飛ばす数
 @result        フィルタ後のリスト
 */
-(NSEnumerator *) skip: (int) count;

/*!
 @abstract      条件に一致する間は読み飛ばす
 @param         predicate 判定関数
 @result        フィルタ後のリスト
 */
-(NSEnumerator *) skipWhile: (BOOL(^)(id)) predicate;

/*!
 @abstract      条件に一致する間は読み飛ばす
 @discussion    条件に一致する間は読み飛ばす(index付)
 @param         predicate 判定関数
 @result        フィルタ後のリスト
 */
-(NSEnumerator *) skipWhileWithIndex: (BOOL(^)(id,int)) predicate;

/*!
 @abstract      指定された数だけ取得する
 @param         count 取得する数
 @result        フィルタ後のリスト
 */
-(NSEnumerator *) take: (int) count;

/*!
 @abstract      条件に一致する間は取得する
 @param         predicate 判定関数
 @result        フィルタ後のリスト
 */
-(NSEnumerator *) takeWhile: (BOOL(^)(id)) predicate;

/*!
 @abstract      条件に一致する間は取得する
 @discussion    条件に一致する間は取得する(index付)
 @param         predicate 判定関数
 @result        フィルタ後のリスト
 */
-(NSEnumerator *) takeWhileWithIndex: (BOOL(^)(id,int)) predicate;

/*!
 @abstract      リストに関数適用を行い途中結果を列挙する
 @discussion    リストに関数適用を行い途中結果を列挙する
 @param         func 判定関数
 @result        結果リスト
 */
-(NSEnumerator *) scan: (id(^)(id,id)) func;

/*!
 @abstract      ソートする
 @param         firstObj ソート条件(複数指定可)
 @result        フィルタ後のリスト
 */
-(NSEnumerator *) orderByDescription:(NSSortDescriptor *)firstObj, ... NS_REQUIRES_NIL_TERMINATION;

/*!
 @abstract      リストからなるリストを展開する
 @param         selector 変換関数
 @result        展開後のリスト
 */
- (NSEnumerator *) selectMany: (id(^)(id)) selector;

/*!
 @abstract      リストを重複を除外して連結する
 @param         dst 結合する列挙子
 @result        連結後のリスト
 */
- (NSEnumerator *) distinct;

/*!
 @abstract      リストを連結する
 @param         dst 結合する列挙子
 @result        連結後のリスト
 */
- (NSEnumerator *) concat:(NSEnumerator *)dst;

/*!
 @abstract      リストを重複を除外して連結する
 @param         dst 結合する列挙子
 @result        連結後のリスト
 */
- (NSEnumerator *) unions:(NSEnumerator *)dst;

/*!
 @abstract      積集合を取得します
 @discussion    シーケンスの両方に存在している要素のみが抽出されます
 @param         dst 処理する列挙子
 @result        積集合のリスト
 */
- (NSEnumerator *) intersect:(NSEnumerator *)dst;

/*!
 @abstract      差集合を取得します
 @discussion    シーケンスの片方だけに存在している要素のみが抽出されます
 @param         dst 処理する列挙子
 @result        差集合のリスト
 */
- (NSEnumerator *) except:(NSEnumerator *)dst;

/*!
 @abstract      指定個数に区切った配列で取得します
 @discussion    要素を指定個数ずつのNSArrayとして取得します。
 @param         count 要素を区切る数
 @result        count毎に区切られた要素
 */
- (NSEnumerator *) buffer:(int)count;


/*!
 @abstract      NSArrayに変換する
 @result        変換したNSArray
 */
- (NSArray *) toArray;

/*!
 @abstract      NSMutableArrayに変換する
 @result        変換したNSMutableArray
 */
- (NSMutableArray *) toMutableArray;

/*!
 @abstract      NSDictionaryに変換する
 @param         keySelector ディクショナリのKeyへと変換する関数
 @result        変換したNSDictionary
 */
- (NSDictionary *) toDictionary: (id(^)(id)) keySelector;

/*!
 @abstract      NSDictionaryに変換する
 @param         keySelector ディクショナリのKeyへと変換する関数
 @param         elementSelector ディクショナリのElementへと変換する関数
 @result        変換したNSDictionary
 */
- (NSDictionary *) toDictionary: (id(^)(id)) keySelector elementSelector:(id(^)(id)) elementSelector;

/*!
 @abstract      NSMutableDictionaryに変換する
 @param         keySelector ディクショナリのKeyへと変換する関数
 @result        変換したNSMutableDictionary
 */
- (NSDictionary *) toMutableDictionary: (id(^)(id)) keySelector;

/*!
 @abstract      NSMutableDictionaryに変換する
 @param         keySelector ディクショナリのKeyへと変換する関数
 @param         elementSelector ディクショナリのElementへと変換する関数
 @result        変換したNSMutableDictionary
 */
- (NSDictionary *) toMutableDictionary: (id(^)(id)) keySelector elementSelector:(id(^)(id)) elementSelector;


/*!
 @abstract      charからなる配列をNSDataに変換する
 @result        変換したNSData
 */
-(NSData *) toData;

/*!
 @abstract      unicharからなる配列をNSStringに変換する
 @result        変換したNSData
 */
-(NSString *) toString;

#pragma mark - 要素取得系

/*!
 @abstract      指定位置の要素を取得する
 @discussion    要素が無い場合には例外を返す。
 @param         index 取得対象
 @exception     NSInvalidArgumentException   要素がない場合
 @result        フィルタ後のリスト
 */
-(id) elementAt:(int)index;

/*!
 @abstract      指定位置の要素を取得する
 @discussion    要素が無い場合にnilを返す。
 @param         index 取得対象
 @result        フィルタ後のリスト
 */
-(id) elementOrNilAt:(int)index;

/*!
 @abstract      単一要素に変換する
 @discussion    要素が無い場合には例外を返す。
 @exception     NSInvalidArgumentException   要素がない、複数件数ある場合
 @result        フィルタ後のリスト
 */
-(id) single;

/*!
 @abstract      単一要素に変換する
 @discussion    要素が無い場合には例外を返す。
 @param         predicate 判定関数
 @exception     NSInvalidArgumentException   要素がない、複数件数ある場合
 @result        フィルタ後のリスト
 */
-(id) single:(BOOL(^)(id)) predicate;

/*!
 @abstract      単一要素に変換する
 @discussion    要素が無い場合にnilを返す。
 @exception     NSInvalidArgumentException   複数件数ある場合
 @result        フィルタ後のリスト
 */
-(id) singleOrNil;

/*!
 @abstract      単一要素に変換する
 @discussion    要素が無い場合にnilを返す。
 @param         predicate 判定関数
 @exception     NSInvalidArgumentException   複数件数ある場合
 @result        フィルタ後のリスト
 */
-(id) singleOrNil:(BOOL(^)(id)) predicate;



/*!
 @abstract      先頭要素のみ取得する
 @discussion    要素が無い場合には例外を返す。
 @exception     NSInvalidArgumentException   要素がない場合
 @result        フィルタ後のリスト
 */
-(id) first;

/*!
 @abstract      先頭要素のみ取得する
 @discussion    要素が無い場合には例外を返す。
 @param         predicate 判定関数
 @exception     NSInvalidArgumentException   要素がない場合
 @result        フィルタ後のリスト
 */
-(id) first:(BOOL(^)(id)) predicate;


/*!
 @abstract      先頭要素のみ取得する
 @discussion    要素が無い場合にnilを返す。
 @result        フィルタ後のリスト
 */
-(id) firstOrNil;

/*!
 @abstract      先頭要素のみ取得する
 @discussion    要素が無い場合にnilを返す。
 @param         predicate 判定関数
 @result        フィルタ後のリスト
 */
-(id) firstOrNil:(BOOL(^)(id)) predicate;


/*!
 @abstract      最終要素のみ取得する
 @discussion    要素が無い場合には例外を返す。
 @exception     NSInvalidArgumentException   要素がない場合
 @result        フィルタ後のリスト
 */
-(id) last;

/*!
 @abstract      最終要素のみ取得する
 @discussion    要素が無い場合には例外を返す。
 @exception     NSInvalidArgumentException   要素がない場合
 @param         predicate 判定関数
 @result        フィルタ後のリスト
 */
-(id) last:(BOOL(^)(id)) predicate;

/*!
 @abstract      最終要素のみ取得する
 @discussion    要素が無い場合にnilを返す。
 @result        フィルタ後のリスト
 */
-(id) lastOrNil;

/*!
 @abstract      最終要素のみ取得する
 @discussion    要素が無い場合にnilを返す。
 @param         predicate 判定関数
 @result        フィルタ後のリスト
 */
-(id) lastOrNil:(BOOL(^)(id)) predicate;

/*!
 @abstract      件数を取得する
 @result        件数
 */
-(int) count;

/*!
 @abstract      シーケンスの要素がすべて条件を満たすか調べる
 @param         predicate 判定関数
 @result        条件を満たす場合:YES 満たさない場合:NO
 */
-(BOOL) all: (BOOL(^)(id)) predicate;

/*!
 @abstract      シーケンスに条件を満たす要素が含まれるか調べる
 @param         predicate 判定関数
 @result        条件を満たす要素が含まれる場合:YES 含まれない場合:NO
 */
-(BOOL) any: (BOOL(^)(id)) predicate;

/*!
 @abstract      シーケンスに要素が含まれているか調べる
 @param         item 検証する対象
 @result        検証する要素が含まれる場合:YES 含まれない場合:NO
 */
-(BOOL) contains : (id) item;

/*!
 @abstract      シーケンスが一致するか調べる
 @param         dst 比較するリスト
 @result        シーケンスが一致場合:YES 一致しない場合:NO
 */
-(BOOL) sequenceEqual: (NSEnumerator *)dst;

#pragma mark - 処理関数系

/*!
 @abstract      リストに処理を適用する
 @param     action 処理関数
 */
- (void) forEach: (void(^)(id)) action;

#endif

@end