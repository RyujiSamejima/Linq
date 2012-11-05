//
//  NSEnumerator+Additions.h
//  TesApp
//
//  Created by 鮫島 隆治 on 2012/10/27.
//  Copyright (c) 2012年 鮫島 隆治. All rights reserved.
//

#import <Foundation/Foundation.h>

/** カスタムの列挙子
 * 
 *
 */
@interface CustomEnumerator : NSEnumerator
{
    __weak NSEnumerator *_src;
    id (^_nextObject)(NSEnumerator *);
}

- (id)initWithFunction:(NSEnumerator *)src nextObjectBlock:(id(^)(NSEnumerator *))nextObject;
- (id)nextObject;

@end

/** リスト処理用カテゴリ
 * リストに対して様々な処理を提供する
 *
 */
@interface NSEnumerator (Query)

/**************************************************************************/
// 生成系
/**************************************************************************/
/** NSDataからcharのNSEnumerator
 *
 * @param  data   生成元のNSData
 * @throws なし
 * @return フィルタ後のリスト
 */
+(NSEnumerator *)fromNSData:(NSData*)data;

/**************************************************************************/
// 変換系
/**************************************************************************/
/** 指定したクラスの物のみ取得する
 *
 * @param  class   取得対象クラス
 * @throws なし
 * @return フィルタ後のリスト
 */
- (NSEnumerator *) ofClass: (Class) class;

/** リストを変換する
 *
 * @param  selector   変換関数
 * @throws なし
 * @return フィルタ後のリスト
 */
-(NSEnumerator *) select: (id(^)(id)) selector;

/** リストを変換する
 *
 * @param  selector   変換関数
 * @throws なし
 * @return フィルタ後のリスト
 */
-(NSEnumerator *) selectWithIndex: (id(^)(id,int)) selector;

/** 条件に一致するもののみ取得する
 *
 * @param  predicate   判定関数
 * @throws なし
 * @return フィルタ後のリスト
 */
-(NSEnumerator *) where: (BOOL(^)(id)) predicate;

/** 条件に一致するもののみ取得する
 *
 * @param  predicate   判定関数
 * @throws なし
 * @return フィルタ後のリスト
 */
-(NSEnumerator *) whereWithIndex: (BOOL(^)(id,int)) predicate;

/** 指定された数だけ読み飛ばす
 *
 * @param  count   読み飛ばす数
 * @throws なし
 * @return フィルタ後のリスト
 */
-(NSEnumerator *) skip: (int) count;

/** 条件に一致する間は読み飛ばす
 *
 * @param  predicate   判定関数
 * @throws なし
 * @return フィルタ後のリスト
 */
-(NSEnumerator *) skipWhile: (BOOL(^)(id)) predicate;

/** 条件に一致する間は読み飛ばす
 *
 * @param  predicate   判定関数
 * @throws なし
 * @return フィルタ後のリスト
 */
-(NSEnumerator *) skipWhileWithIndex: (BOOL(^)(id,int)) predicate;

/** 指定された数だけ取得する
 *
 * @param  count   取得する数
 * @throws なし
 * @return フィルタ後のリスト
 */
-(NSEnumerator *) take: (int) count;

/** 条件に一致する間は取得する
 *
 * @param  predicate   判定関数
 * @throws なし
 * @return フィルタ後のリスト
 */
-(NSEnumerator *) takeWhile: (BOOL(^)(id)) predicate;

/** 条件に一致する間は取得する
 *
 * @param  predicate   判定関数
 * @throws なし
 * @return フィルタ後のリスト
 */
-(NSEnumerator *) takeWhileWithIndex: (BOOL(^)(id,int)) predicate;

/** ソートする
 *
 * @param  firstObj   ソート条件
 * @throws なし
 * @return ソート後のリスト
 */
-(NSEnumerator *) orderByDescription:(NSSortDescriptor *)firstObj, ... NS_REQUIRES_NIL_TERMINATION;

/** リストからなるリストを展開する
 *
 * @param  なし
 * @throws なし
 * @return 展開後のリスト
 */
- (NSEnumerator *) selectMany: (id(^)(id)) selector;

/** リストを連結する
 *
 * @param  なし
 * @throws なし
 * @return 連結後のリスト
 */
- (NSEnumerator *) concat:(NSEnumerator *)dst;

/** NSMutableArrayに変換する
 *
 * @param  なし
 * @throws なし
 * @return NSMutableArray
 */
- (NSMutableArray *) toArray;

/** charからなる配列をNSDataに変換する
 *
 * @param  なし
 * @throws なし
 * @return NSMutableArray
 */
-(NSData *) toNSData;

/**************************************************************************/
// 要素取得系
/**************************************************************************/
/** 単一要素に変換する
 *
 * @param  なし
 * @throws NSInvalidArgumentException   要素がない、複数件数ある場合
 * @return フィルタ後のリスト
 */
-(id) single;

/** 単一要素に変換する
 *
 * @param  なし
 * @throws NSInvalidArgumentException   複数件数ある場合
 * @return フィルタ後のリスト
 */
-(id) singleOrNil;

/** 指定位置の要素を取得する
 *
 * @param  index   取得対象クラス
 * @throws NSInvalidArgumentException   要素がない場合
 * @return フィルタ後のリスト
 */
-(id) elementAt:(int)index;

/** 指定位置の要素を取得する
 *
 * @param  index   取得位置
 * @throws なし
 * @return フィルタ後のリスト
 */
-(id) elementOrNilAt:(int)index;

/** 先頭要素のみ取得する
 *
 * @param  なし
 * @throws NSInvalidArgumentException   要素がない場合
 * @return フィルタ後のリスト
 */
-(id) first;

/** 先頭要素のみ取得する
 *
 * @param  なし
 * @throws なし
 * @return フィルタ後のリスト
 */
-(id) firstOrNil;

/** 最終要素のみ取得する
 *
 * @param  なし
 * @throws NSInvalidArgumentException   要素がない場合
 * @return フィルタ後のリスト
 */
-(id) last;

/** 最終要素のみ取得する
 *
 * @param  class   取得対象クラス
 * @throws なし
 * @return フィルタ後のリスト
 */
-(id) lastOrNil;


/** 件数を取得する
 *
 * @param  なし
 * @throws なし
 * @return フィルタ後のリスト
 */
-(int) count;

/** シーケンスの要素がすべて条件を満たすか調べる
 *
 * @param  predicate   判定関数
 * @throws なし
 * @return なし
 */
-(BOOL) all: (BOOL(^)(id)) predicate;

/** シーケンスに条件を満たす要素が含まれるか調べる
 *
 * @param  predicate   判定関数
 * @throws なし
 * @return なし
 */
-(BOOL) any: (BOOL(^)(id)) predicate;

/** シーケンスに要素が含まれているか調べる
 *
 * @param  item   検証する要素
 * @throws なし
 * @return なし
 */
-(BOOL) contains : (id) item;

/** シーケンスが一致するか調べる
 *
 * @param  dst   比較するリスト
 * @throws なし
 * @return なし
 */
-(BOOL) sequenceEqual: (NSEnumerator *)dst;


/**************************************************************************/
// 処理関数系
/**************************************************************************/
/** リストに処理を適用する
 *
 * @param  action   処理関数
 * @throws なし
 * @return なし
 */
- (void) forEach: (void(^)(id)) action;

@end
