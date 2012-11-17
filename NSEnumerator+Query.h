//
//  NSEnumerator+Query.h
//  Agent
//
//

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
    id (^_nextObject)(NSEnumerator * src);
}

/*!
 @abstract      CustomEnemeratorを作成する。
 @discussion    nextObjectの実行ブロックで初期化する。
 @param         src データ取得元
 @param         nextObject 次の要素
 @result        初期化されたCustomEnumerator
*/
- (id)initWithFunction:(NSEnumerator *)src nextObjectBlock:(id(^)(NSEnumerator *))nextObject;

/*!
 @abstract      次の要素を取得する。
 @result        次の要素
 */
- (id)nextObject;

@end

/*!
 @abstract      リスト処理用カテゴリ
 @discussion    リストに対して様々な処理を提供する
 */
@interface NSEnumerator (Query)


#pragma mark - 生成系
/*!
 @abstract      NSDataから列挙子を作成する。
 @discussion    NSData１バイト毎のchar配列の列挙子で初期化する。
 @param         data 生成元のNSData
 @result        作成されたEnumerator
 */
+(NSEnumerator *)fromNSData:(NSData*)data;

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
 @param         item 要素
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
 @param         class 取得対象クラス
 @result        フィルタ後のリスト
 */
- (NSEnumerator *) ofClass: (Class) class;

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
- (NSEnumerator *) union:(NSEnumerator *)dst;

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
 @param         count 処理する列挙子
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
 @result        変換したNSDictionary
 */
- (NSDictionary *) toDictionary: (id(^)(id)) keySelector elementSelector:(id(^)(id)) elementSelector;

/*!
 @abstract      charからなる配列をNSDataに変換する
 @result        変換したNSData
 */
-(NSData *) toNSData;

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
 @param         item 検証する要素
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
- (void) forEach: (void(^)(id item)) action;

@end
