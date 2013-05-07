//
//  LQXDocument.h
//  LinqTestApp
//
//  Copyright (c) 2013 Ryuji Samejima. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <libxml/tree.h>
#include <libxml/xmlreader.h>

#import "NSEnumerator+Query.h"

/*!
 @enum        XmlNodeType
 @abstract    Xml要素の種類
 @constant    XmlNodeTypeNone
 */
typedef enum {
    XmlNodeTypeNone = 0
    , XmlNodeTypeElement
    , XmlNodeTypeAttribute
//    , XmlNodeTypeText
//    , XmlNodeTypeCDATA
//    , XmlNodeTypeEntityReference
//    , XmlNodeTypeEntity
//    , XmlNodeTypeProcessingInstruction
    , XmlNodeTypeComment
    , XmlNodeTypeDocument
    , XmlNodeTypeDocumentType
//    , XmlNodeTypeDocumentFragment
//    , XmlNodeTypeNotation
//    , XmlNodeTypeWhitespace
//    , XmlNodeTypeSignificantWhitespace
    , XmlNodeTypeEndElement
    , XmlNodeTypeXmlDeclaration
} XmlNodeType;

/*!
 @abstract      XMLの要素名称
 @discussion    名前空間と名称を保持するクラス
 */
@interface LQXName : NSObject

/*! 要素名 */
@property (nonatomic,readonly) NSString *localName;
/*! 名前空間名称 */
@property (nonatomic,readonly) NSString *nameSpaceName;

/*!
 @abstract      LQXNameを取得する
 @discussion    "{namespace}localname"形式の文字列からLQXNameを生成する
 @param         name 文字列
 @result        LQXName
 */
+(LQXName*)name:(NSString*)name;
/*!
 @abstract      LQXNameを取得する
 @discussion    名前空間と要素名称からLQXNameを生成する
 @param         nameSpace 名前空間
 @param         localName 要素名称
 @result        LQXName
 */
+(LQXName*)nameSpace:(NSString*)nameSpace localName:(NSString*)localName;

/*!
 @abstract      LQXNameを取得する
 @discussion    "{namespace}localname"形式の文字列からLQXNameを生成する
 @param         name 文字列
 @result        LQXName
 */
-(LQXName*)init:(NSString*)name;
/*!
 @abstract      LQXNameを取得する
 @discussion    名前空間と要素名称からLQXNameを生成する
 @param         nameSpace 名前空間
 @param         localName 要素名称
 @result        LQXName
 */
-(LQXName*)initWithNameSpace:(NSString*)nameSpace localName:(NSString*)localName;

/*!
 @abstract      文字列を取得する
 @discussion    "{namespace}localname"形式の文字列で取得する
 @result        "{namespace}localname"
 */
-(NSString*)toString;

@end

/*!
 @abstract      XMLのドキュメント定義
 @discussion    XMLのバージョンとエンコーディングを保持するクラス
 */
@interface LQXDeclaration : NSObject

/*! エンコーディング */
@property (nonatomic,assign) NSStringEncoding encoding;
/*!  */
@property (nonatomic,copy) NSString *version;

/*!
 @abstract      LQXDeclarationを取得する
 @discussion    エンコーディングとドキュメントバージョンからLQXDeclarationを生成する
 @param         encoding エンコーディング
 @param         version ドキュメントバージョン
 @result        LQXDeclaration
 */
+(LQXDeclaration*)declareWithEncoding:(NSStringEncoding)encoding version:(NSString*)version;
/*!
 @abstract      LQXDeclarationを取得する
 @discussion    エンコーディングとドキュメントバージョンからLQXDeclarationを生成する
 @param         encoding エンコーディング
 @param         version ドキュメントバージョン
 @result        LQXDeclaration
 */
-(LQXDeclaration*)initWithEncoding:(NSStringEncoding)encoding version:(NSString*)version;

@end

@class LQXDocument;
@class LQXElement;

/*!
 @abstract      XML要素の基本クラス
 @discussion    XML要素の基本クラス
 */
@interface LQXObject : NSObject

/*! この要素が属するLQXDocument */
@property (nonatomic,readonly) LQXDocument *document;
/*! 要素の種類 */
@property (nonatomic,readonly) XmlNodeType nodeType;
/*! 要素の親要素 */
@property (nonatomic,readonly) LQXElement *parent;

@end

/*!
 @abstract      属性
 @discussion    属性クラス
 */
@interface LQXAttribute : LQXObject

/*! 属性の名称 */
@property (nonatomic,readonly) NSString *name;
/*! 値 */
@property (nonatomic,copy) NSString *value;
///*! 次の要素 */
//@property (nonatomic,readonly) NSString *nextAttribute;
///*! 前の要素 */
//@property (nonatomic,readonly) NSString *previousAttribute;;

/*!
 @abstract      LQXAttributeを取得する
 @discussion    元となるLQXAttributeからLQXAttributeを生成する
 @param         attribute 元になるLQXAttribute
 @result        LQXAttribute
 */
+(LQXAttribute*)attributeWithAttribute:(LQXAttribute*)attribute;
/*!
 @abstract      LQXAttributeを取得する
 @discussion    要素名称と値のペアからLQXAttributeを生成する
 @param         name 要素名称
 @param         value 値
 @result        LQXAttribute
 */
+(LQXAttribute*)attribute:(NSString*)name value:(NSString*)value;
/*!
 @abstract      LQXAttributeを取得する
 @discussion    要素名称と値のペアからLQXAttributeを生成する
 @param         name 要素名称
 @param         value 値
 @result        LQXAttribute
 */
+(LQXAttribute*)attributeWithXName:(LQXName*)name value:(NSString*)value;

/*!
 @abstract      LQXAttributeを取得する
 @discussion    元となるLQXAttributeからLQXAttributeを生成する
 @param         attribute 元になるLQXAttribute
 @result        LQXAttribute
 */
-(LQXAttribute*)initWithAttribute:(LQXAttribute*)attribute;
/*!
 @abstract      LQXAttributeを取得する
 @discussion    要素名称と値のペアからLQXAttributeを生成する
 @param         name 要素名称
 @param         value 値
 @result        LQXAttribute
 */
-(LQXAttribute*)init:(NSString*)name value:(NSString*)value;
/*!
 @abstract      LQXAttributeを取得する
 @discussion    要素名称と値のペアからLQXAttributeを生成する
 @param         name 要素名称
 @param         value 値
 @result        LQXAttribute
 */
-(LQXAttribute*)initWithXName:(LQXName*)name value:(NSString*)value;

/*!
 @abstract      親要素から自身を取り除く
 @discussion    親要素から自身を取り除く
 */
-(void)remove;

@end

/*!
 @abstract      XML要素の基本クラス
 @discussion    XML要素の基本クラス
 */
@interface LQXNode : LQXObject

///*! 次の要素 */
//@property (nonatomic) LQXNode *nextNode;
///*! 前の要素 */
//@property (nonatomic) LQXNode *previousNode;

//-(void)addAfterSelf:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
//-(void)addBeforeSelf:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
//-(NSEnumerator*)ancestors;
//-(NSEnumerator*)ancestors:(LQXName*)name;
//-(NSEnumerator*)elementsAfterSelf;
//-(NSEnumerator*)elementsAfterSelf:(LQXName*)name;
//-(NSEnumerator*)elementsBeforeSelf;
//-(NSEnumerator*)elementsBeforeSelf:(LQXName*)name;
//-(NSEnumerator*)nodesAfterSelf;
//-(NSEnumerator*)nodesBeforeSelf;
/*!
 @abstract      親要素から自身を取り除く
 @discussion    親要素から自身を取り除く
 */
-(void)remove;

@end

@class LQXElement;

/*!
 @abstract      子要素を持つXML要素の基本クラス
 @discussion    LQXElement、LQXDocumentの基本クラス
 */
@interface LQXContainer : LQXNode

///*! 最初のノード */
//@property (nonatomic) LQXNode *firstNode;
///*! 最後のノード */
//@property (nonatomic) LQXNode *lastNode;

/*!
 @abstract      子要素を追加する
 @discussion    子要素を追加する。追加する要素の型により振る舞いが異なる。LQXAttributeであれば属性として追加、LQXElementであれば子要素として追加、NSArray型であれば列挙して全てを子要素として追加する。
 @param         firstObj 追加する要素
 */
-(void)add:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
/*!
 @abstract      子孫を列挙する
 @discussion    子孫を列挙する
 @result        NSEnumerator
 */
-(NSEnumerator*)descendants;
/*!
 @abstract      子孫を列挙する
 @discussion    子孫を列挙する
 @param         name フィルタ名
 @result        NSEnumerator
 */
-(NSEnumerator*)descendants:(NSString*)name;
/*!
 @abstract      子孫を列挙する
 @discussion    子孫を列挙する
 @param         name フィルタ名
 @result        NSEnumerator
 */
-(NSEnumerator*)descendantsWithName:(LQXName*)name;
/*!
 @abstract      子要素を取得する
 @discussion    子要素を取得する
 @param         name フィルタ名
 @result        LQXElement
 */
-(LQXElement*)element:(NSString*)name;
/*!
 @abstract      子要素を取得する
 @discussion    子要素を取得する
 @param         name フィルタ名
 @result        LQXElement
 */
-(LQXElement*)elementWithName:(LQXName*)name;
/*!
 @abstract      子要素を列挙する
 @discussion    子要素を列挙する
 @result        NSEnumerator
 */
-(NSEnumerator*)elements;
/*!
 @abstract      子要素を列挙する
 @discussion    子要素を列挙する
 @param         name フィルタ名
 @result        NSEnumerator
 */
-(NSEnumerator*)elements:(NSString*)name;
/*!
 @abstract      子要素を列挙する
 @discussion    子要素を列挙する
 @param         name フィルタ名
 @result        NSEnumerator
 */
-(NSEnumerator*)elementsWithName:(LQXName*)name;

/*!
 @abstract      子要素を削除する
 @discussion    子要素を削除する
 */
-(void)removeNodes;

@end

/*!
 @abstract      XML要素クラス
 @discussion    値と属性、子ノードを持つXML要素クラス
 */
@interface LQXElement : LQXContainer

/*! 要素名称 */
@property (nonatomic,readonly) NSString *name;
/*! 値 */
@property (nonatomic,copy) NSString *value;
/*! 最初の属性値 */
@property(nonatomic,readonly) LQXAttribute* firstAttribute;
/*! 属性があるか */
@property(nonatomic,readonly) BOOL hasAttributes;
/*! 子要素があるか */
@property(nonatomic,readonly) BOOL hasElements;

/*!
 @abstract      LQXElementを取得する
 @discussion    元となるとLQXElementからLQXElementを生成する
 @param         element 元となるLQXElement
 @result        LQXElement
 */
+(LQXElement*)elementWithElement:(LQXElement*)element;
/*!
 @abstract      LQXElementを取得する
 @discussion    要素名称からLQXElementを生成する
 @param         name 要素名称
 @result        LQXElement
 */
+(LQXElement*)element:(NSString*)name;
/*!
 @abstract      LQXElementを取得する
 @discussion    要素名称からLQXElementを生成する
 @param         name 要素名称
 @result        LQXElement
 */
+(LQXElement*)elementWithXName:(LQXName*)name;
/*!
 @abstract      LQXElementを取得する
 @discussion    要素名称と値からLQXElementを生成する
 @param         name 要素名称
 @param         value 値
 @result        LQXElement
 */
+(LQXElement*)element:(NSString*)name value:(NSString*)value;
/*!
 @abstract      LQXElementを取得する
 @discussion    要素名称と値からLQXElementを生成する
 @param         name 要素名称
 @param         value 値
 @result        LQXElement
 */
+(LQXElement*)elementWithXName:(LQXName*)name value:(NSString*)value;
/*!
 @abstract      LQXElementを取得する
 @discussion    要素名称と子要素からLQXElementを生成する
 @param         name 要素名称
 @param         firstObject 子要素
 @result        LQXElement
 */
+(LQXElement*)element:(NSString*)name objects:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
/*!
 @abstract      LQXElementを取得する
 @discussion    要素名称と子要素からLQXElementを生成する
 @param         name 要素名称
 @param         firstObject 子要素
 @result        LQXElement
 */
+(LQXElement*)elementWithXName:(LQXName*)name objects:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

/*!
 @abstract      xmlドキュメントを読み込む
 @discussion    xmlドキュメントからDOMを構築する
 @param         filename ファイル名
 */
+(LQXElement*)load:(NSString*)filename;

/*!
 @abstract      LQXElementを取得する
 @discussion    元となるとLQXElementからLQXElementを生成する
 @param         element 元となるLQXElement
 @result        LQXElement
 */
-(LQXElement*)initWithElement:(LQXElement*)element;
/*!
 @abstract      LQXElementを取得する
 @discussion    要素名称からLQXElementを生成する
 @param         name 要素名称
 @result        LQXElement
 */
-(LQXElement*)init:(NSString*)name;
/*!
 @abstract      LQXElementを取得する
 @discussion    要素名称からLQXElementを生成する
 @param         name 要素名称
 @result        LQXElement
 */
-(LQXElement*)initWithXName:(LQXName*)name;
/*!
 @abstract      LQXElementを取得する
 @discussion    要素名称と値からLQXElementを生成する
 @param         name 要素名称
 @param         value 値
 @result        LQXElement
 */
-(LQXElement*)init:(NSString*)name value:(NSString*)value;
/*!
 @abstract      LQXElementを取得する
 @discussion    要素名称と値からLQXElementを生成する
 @param         name 要素名称
 @param         value 値
 @result        LQXElement
 */
-(LQXElement*)initWithXName:(LQXName*)name value:(NSString*)value;
/*!
 @abstract      LQXElementを取得する
 @discussion    要素名称と子要素からLQXElementを生成する
 @param         name 要素名称
 @param         firstObject 子要素
 @result        LQXElement
 */
-(LQXElement*)init:(NSString*)name objects:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
/*!
 @abstract      LQXElementを取得する
 @discussion    要素名称と子要素からLQXElementを生成する
 @param         name 要素名称
 @param         firstObject 子要素
 @result        LQXElement
 */
-(LQXElement*)initWithXName:(LQXName*)name objects:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

/*!
 @abstract      属性を取得する
 @discussion    属性を取得する
 @param         name フィルタ名
 @result        LQXAttribute
 */
-(LQXAttribute*)attribute:(NSString*)name;
/*!
 @abstract      属性を取得する
 @discussion    属性を取得する
 @param         name フィルタ名
 @result        LQXAttribute
 */
-(LQXAttribute*)attributeWithName:(LQXName*)name;
/*!
 @abstract      属性を列挙する
 @discussion    属性を列挙する
 @result        NSEnumerator
 */
-(NSEnumerator*)attributes;
/*!
 @abstract      属性を列挙する
 @discussion    属性を列挙する
 @param         name フィルタ名
 @result        NSEnumerator
 */
-(NSEnumerator*)attributes:(NSString*)name;
/*!
 @abstract      属性を列挙する
 @discussion    属性を列挙する
 @param         name フィルタ名
 @result        NSEnumerator
 */
-(NSEnumerator*)attributesWithName:(LQXName*)name;

/*!
 @abstract      属性と子要素を削除する
 @discussion    属性と子要素を削除する
 */
-(void)removeAll;
/*!
 @abstract      属性を削除する
 @discussion    属性を削除する
 */
-(void)removeAttributes;
/*!
 @abstract      属性を変更する
 @discussion    属性を変更する。valueがnilの場合は属性を削除する。
 @param         name 変更する名称
 @param         value 値
 */
-(void)setAttribute:(NSString*)name value:(NSString*)value;
/*!
 @abstract      属性を変更する
 @discussion    属性を変更する。valueがnilの場合は属性を削除する。
 @param         name 変更する名称
 @param         value 値
 */
-(void)setAttributeWithName:(LQXName*)name value:(NSString*)value;
/*!
 @abstract      子要素を変更する
 @discussion    子要素を変更する。valueがnilの場合は子要素を削除する。
 @param         name 変更する名称
 @param         value 値
 */
-(void)setElement:(NSString*)name value:(NSString*)value;
/*!
 @abstract      子要素を変更する
 @discussion    子要素を変更する。valueがnilの場合は子要素を削除する。
 @param         name 変更する名称
 @param         value 値
 */
-(void)setElementWithName:(LQXName*)name value:(NSString*)value;

@end

/*!
 @abstract      XMLドキュメントクラス
 @discussion    XMLドキュメントを保持するクラス
 */
@interface LQXDocument : LQXContainer

/*! ルート要素 */
@property (nonatomic,readonly) LQXElement *root;
/*! XMLエンコーディング定義 */
@property (nonatomic,retain) LQXDeclaration *declaration;

/*!
 @abstract      LQXDocumentを取得する
 @discussion    元となるLQXDocumentからLQXDocumentを生成する
 @param         document 元となるLQXDocument
 @result        LQXDocument
 */
+(LQXDocument*)documentWithDocument:(LQXDocument*)document;
/*!
 @abstract      LQXDocumentを取得する
 @discussion    LQXDocumentを生成して子要素を追加する
 @param         firstObject 子要素
 @result        LQXDocument
 */
+(LQXDocument*)documentWithObject:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
/*!
 @abstract      LQXDocumentを取得する
 @discussion    LQXDeclarationからLQXDocumentを生成して子要素を追加する
 @param         declaration エンコーティング定義
 @param         firstObject 子要素
 @result        LQXDocument
 */
+(LQXDocument*)documentWithDeclaration:(LQXDeclaration*)declaration objects:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

-(LQXDocument*)init;
/*!
 @abstract      LQXDocumentを取得する
 @discussion    元となるLQXDocumentからLQXDocumentを生成する
 @param         document 元となるLQXDocument
 @result        LQXDocument
 */
-(LQXDocument*)initWithDocument:(LQXDocument*)document;
/*!
 @abstract      LQXDocumentを取得する
 @discussion    LQXDocumentを生成して子要素を追加する
 @param         firstObject 子要素
 @result        LQXDocument
 */
-(LQXDocument*)initWithObjects:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
/*!
 @abstract      LQXDocumentを取得する
 @discussion    LQXDeclarationからLQXDocumentを生成して子要素を追加する
 @param         declaration エンコーティング定義
 @param         firstObject 子要素
 @result        LQXDocument
 */
-(LQXDocument*)initWithDeclaration:(LQXDeclaration*)declaration objects:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

@end



