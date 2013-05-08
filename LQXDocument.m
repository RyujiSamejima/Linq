//
//  LQXDocument.m
//  LinqTestApp
//
//  Copyright (c) 2013 Ryuji Samejima. All rights reserved.
//

#import "LQXDocument.h"
#import "NSEnumerator+Query.h"

#pragma mark - interface

@interface LQXName()

@property (nonatomic,readwrite) NSString *localName;
@property (nonatomic,readwrite) NSString *nameSpaceName;

@end

@interface LQXObject()

@property (nonatomic,readwrite) LQXDocument *document;
@property (nonatomic,readwrite) LQXElement *parent;

@end

@interface LQXAttribute()

@property (nonatomic,readwrite) LQXName *name;

@end

@interface LQXNode()
@end

@interface LQXComment()

@end

@interface LQXContainer()

-(void)addObject:(id)object;
@property (nonatomic,readwrite) NSMutableArray *nodeArray;

@end

@interface LQXElement()

@property (nonatomic,readwrite) LQXName *name;
@property (nonatomic,readwrite) NSMutableArray *attributeArray;

-(void)addObject:(id)object;

@end

@interface LQXDocument()

@property (nonatomic,readwrite) LQXElement *root;

-(void)addObject:(id)object;

@end

#pragma mark - implementation
#pragma mark LQXName
@implementation LQXName

+(LQXName*)name:(NSString*)name {
    return [[LQXName alloc]init:name];
}

+(LQXName*)nameSpace:(NSString*)nameSpace localName:(NSString*)localName {
    return [[LQXName alloc]initWithNameSpace:nameSpace localName:localName];
}


-(LQXName*)init:(NSString*)name {
    if ((self = [super init])) {
        if (![[name substringToIndex:1]isEqualToString:@"{"]) {
            self.nameSpaceName = @"";
            self.localName = name;
        } else {
            NSRange endBlace = [name rangeOfString:@"}"];
            if (endBlace.location != NSNotFound) {
                self.nameSpaceName = [name substringWithRange:NSMakeRange(1, endBlace.location - 1)];
                self.localName = [name substringFromIndex:endBlace.location + 1];
            } else {
                self.localName = name;
            }
        }
    }
    return self;
}
-(LQXName*)initWithNameSpace:(NSString*)nameSpace localName:(NSString*)localName {
    if ((self = [super init])) {
        self.nameSpaceName = nameSpace;
        self.localName = localName;
    }
    return self;
}

-(NSString*)toString {
    if ([self.nameSpaceName isEqualToString:@""]) {
        return self.localName;
    } else {
        return [NSString stringWithFormat:@"{%@}%@",self.nameSpaceName, self.localName];
    }
}

-(NSString *)description {
    return [self toString];
}

@end

#pragma mark LQXNameSpace

@implementation LQXDeclaration

+(LQXDeclaration*)declareWithEncoding:(NSStringEncoding)encoding version:(NSString*)version {
    return [[LQXDeclaration alloc]initWithEncoding:encoding version:version];
}

-(LQXDeclaration*)initWithEncoding:(NSStringEncoding)encoding version:(NSString*)version {
    if ((self = [super init])) {
        self.encoding = encoding;
        self.version = version;
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<?xml version=\"%@\" encoding=\"%@\"?>\n",self.version, CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.encoding))];
}
@end

#pragma mark LQXObject

@implementation LQXObject

@end

#pragma mark LQXAttribute

@implementation LQXAttribute {
    NSString *_value;
}

//@property (readonly) NSString *nextAttribute;
//@property (readonly) NSString *previousAttribute;;

@dynamic value;
-(NSString *)value {
    return _value;
}
-(void)setValue:(NSString *)value {
    _value = value;
}

@dynamic nodeType;
-(XmlNodeType)nodeType {
    return XmlNodeTypeAttribute;
}

+(LQXAttribute*)attributeWithAttribute:(LQXAttribute*)attribute {
    return [[LQXAttribute alloc]initWithAttribute:attribute];
}
+(LQXAttribute*)attribute:(NSString*)name value:(NSString*)value {
    return [[LQXAttribute alloc]init:name value:value];
}
+(LQXAttribute*)attributeWithXName:(LQXName*)name value:(NSString*)value {
    return [[LQXAttribute alloc]initWithXName:name value:value];
}

-(LQXAttribute*)initWithAttribute:(LQXAttribute*)attribute {
    if ((self = [super init])) {
        self.name = attribute.name;
        self.value = attribute.value;
    }
    return self;
}

-(LQXAttribute*)init:(NSString*)name value:(NSString*)value {
    if ((self = [super init])) {
        self.name = [LQXName name:name];
        self.value = value;
    }
    return self;
}

-(LQXAttribute*)initWithXName:(LQXName*)name value:(NSString*)value {
    if ((self = [super init])) {
        self.name = name;
        self.value = value;
    }
    return self;
}

-(void)remove {
    if (self.parent != nil) {
        [self.parent.attributeArray removeObject:[self.parent.attributes singleOrNil:^BOOL(id item) {
            return [[((LQXAttribute*)item).name toString] isEqualToString:[self.name toString]];
        }]];
    }
}

-(NSString *)description {
    return [NSString stringWithFormat:@" %@=\"%@\"",self.name.localName, self.value];
}

@end

#pragma mark LQXNode

@implementation LQXNode

//-(void)addAfterSelf:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION {
//
//}
//-(void)addBeforeSelf:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION {
//
//}
//-(NSEnumerator*)ancestors {
//
//}
//-(NSEnumerator*)ancestors:(LQXName*)name {
//
//}
//-(NSEnumerator*)elementsAfterSelf;
//-(NSEnumerator*)elementsAfterSelf:(LQXName*)name;
//-(NSEnumerator*)elementsBeforeSelf;
//-(NSEnumerator*)elementsBeforeSelf:(LQXName*)name;
//-(NSEnumerator*)nodesAfterSelf;
//-(NSEnumerator*)nodesBeforeSelf;
-(void)remove {
    [self.parent.nodeArray removeObject:self];
}

@end

#pragma mark LQXComment

@implementation LQXComment {
    id _value;
}

@dynamic nodeType;
-(XmlNodeType)nodeType {
    return XmlNodeTypeComment;
}

+(LQXComment*)comment:(NSString*)value {
    return [[LQXComment alloc]init:value];
}

+(LQXComment*)commentWithComment:(LQXComment*)comment {
    return [[LQXComment alloc]initWithComment:comment];
}

-(LQXComment*)init:(NSString*)value {
    if ((self = [super init])) {
        _value = value;
    }
    return self;
}

-(LQXComment*)initWithComment:(LQXComment*)comment {
    if ((self = [super init])) {
        _value = comment.value;
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<!--%@-->\n",self.value];
}

@end

#pragma mark LQXContainer

@class LQXElement;

@implementation LQXContainer {
}

-(void)add:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION {
    va_list list;
    va_start(list, firstObject);
    [self addObject:firstObject];
    id object;
    while((object = va_arg(list, id))) {
        [self addObject:object];
    }
    va_end(list);
}

-(NSEnumerator*)descendants {
    return [self.nodeArray.objectEnumerator selectMany:^id(id item) {
        return item;
    }];
}
-(NSEnumerator*)descendants:(NSString*)name {
    return [[[self.nodeArray.objectEnumerator selectMany:^id(id item) {
        return item;
    }]ofClass:[LQXElement class]]where:^BOOL(id item) {
        LQXElement *element = item;
        return [[element.name toString] isEqualToString:name];
    }];
}

-(NSEnumerator*)descendantsWithName:(LQXName*)name {
    return [[[self.nodeArray.objectEnumerator selectMany:^id(id item) {
        return item;
    }]ofClass:[LQXElement class]]where:^BOOL(id item) {
        LQXElement *element = item;
        return [[element.name toString] isEqualToString:[name toString]];
    }];
}
-(LQXElement*)element:(NSString*)name {
    return [[self.nodeArray.objectEnumerator ofClass:[LQXElement class]]singleOrNil:^BOOL(id item) {
        LQXElement *element = item;
        return [[element.name toString] isEqualToString:name];
    }];
}
-(LQXElement*)elementWithName:(LQXName*)name {
    return [[self.nodeArray.objectEnumerator ofClass:[LQXElement class]]singleOrNil:^BOOL(id item) {
        LQXElement *element = item;
        return [[element.name toString] isEqualToString:[name toString]];
    }];
}

-(NSEnumerator*)elements {
    return [self.nodeArray.objectEnumerator ofClass:[LQXElement class]];
}
-(NSEnumerator*)elements:(NSString*)name {
    return [[self.nodeArray.objectEnumerator ofClass:[LQXElement class]]where:^BOOL(id item) {
        LQXElement *element = item;
        return [[element.name toString] isEqualToString:name];
    }];
}
-(NSEnumerator*)elementsWithName:(LQXName*)name {
    return [[self.nodeArray.objectEnumerator ofClass:[LQXElement class]]where:^BOOL(id item) {
        LQXElement *element = item;
        return [[element.name toString] isEqualToString:[name toString]];
    }];
}

-(void)removeNodes {
    self.nodeArray = [[NSMutableArray alloc]init];
}

//継承したLQXElement or LQXDocumentに委譲する
-(void)addObject:(id)object { }

@end

#pragma mark LQXElement

@implementation LQXElement {
    id _value;
}

@dynamic value;
-(NSString *)value {
    return _value;
}
-(void)setValue:(NSString *)value {
    _value = value;
}

@dynamic nodeType;
-(XmlNodeType)nodeType {
    return XmlNodeTypeElement;
}

@dynamic firstAttribute;
-(LQXAttribute *)firstAttribute {
    if (self.hasAttributes) {
        return [self.attributeArray objectAtIndex:0];
    } else {
        return nil;
    }
}
@dynamic isEmpty;
-(BOOL)isEmpty {
    return (!self.hasValue && self.nodeArray.count == 0);
}

@dynamic hasValue;
-(BOOL)hasValue {
    return (self.value != nil && [self.value isEqualToString:@""]);
}

@dynamic hasAttributes;
-(BOOL)hasAttributes {
    return (self.attributeArray.count != 0);
}

@dynamic hasElements;
-(BOOL)hasElements {
    return ([self.elements count] != 0);
}

+(LQXElement*)elementWithElement:(LQXElement*)element {
    return [[LQXElement alloc]initWithElement:element];
}
+(LQXElement*)element:(NSString*)name {
    return [[LQXElement alloc]init:name];
}
+(LQXElement*)elementWithXName:(LQXName*)name {
    return [[LQXElement alloc]initWithXName:name];
}
+(LQXElement*)element:(NSString*)name value:(NSString*)value {
    return [[LQXElement alloc]init:name value:value];
}
+(LQXElement*)elementWithXName:(LQXName*)name value:(NSString*)value {
    return [[LQXElement alloc]initWithXName:name value:value];
}
+(LQXElement*)element:(NSString*)name objects:(id)firstObject, ... {
    LQXElement *element = [LQXElement element:name];
    va_list list;
    va_start(list, firstObject);
    [element addObject:firstObject];
    id object;
    while((object = va_arg(list, id))) {
        [element addObject:object];
    }
    va_end(list);
    return element;
}
+(LQXElement*)elementWithXName:(LQXName*)name objects:(id)firstObject, ... {
    LQXElement *element = [LQXElement elementWithXName:name];
    va_list list;
    va_start(list, firstObject);
    [element addObject:firstObject];
    id object;
    while((object = va_arg(list, id))) {
        [element addObject:object];
    }
    va_end(list);
    return element;
}

+(LQXElement*)load:(NSString*)path {
    LQXElement *result;
    int ret;
    xmlTextReaderPtr  reader;
    const char *input_file = [path cStringUsingEncoding:NSUTF8StringEncoding];
    reader = xmlReaderForFile(input_file, NULL, 0);
    if (NULL == reader) {
        fprintf(stderr, "Failed to parse %s\n", input_file);
        return nil;
    }
    
    NSMutableDictionary *nameSpaces = [[NSMutableDictionary alloc]init];
    
    /* Parse XML */
    while (1 == (ret = xmlTextReaderRead(reader))) {
        result = [self processNode:reader target:result nameSpaces:nameSpaces];
    }
    
    if (0 != ret) {
        fprintf(stderr, "%s : failed to parse\n", input_file);
    }
    
    /* Free reader */
    xmlFreeTextReader(reader);
    
    xmlCleanupParser();
    
    return result;
}

+(LQXElement *)processNode:(xmlTextReaderPtr)reader target:(LQXElement *)target nameSpaces:(NSMutableDictionary*)dictionary {
    
    NSString *name;
    NSString *value;
    int ret;
    /* Print node infos */
    const xmlChar *xmlName = xmlTextReaderConstName(reader);
    
    if (NULL == xmlName) {
        name = @"--";
    } else {
        name = [NSString stringWithCString:(const char*)xmlName encoding:NSUTF8StringEncoding];
    }
    
    switch (xmlTextReaderNodeType(reader)) {
        case XML_READER_TYPE_ELEMENT:
            if (target == nil) {
                target = [LQXElement element:name];
            } else {
                LQXElement *newTarget = [LQXElement element:name];
                [target add:newTarget, nil];
                target = newTarget;
            }
            BOOL isEmpty = (1 == xmlTextReaderIsEmptyElement(reader));
            if (1 == xmlTextReaderHasAttributes(reader)) {
                ret = xmlTextReaderMoveToFirstAttribute(reader);
                while(1 == ret) {
                    NSString *attrName = [NSString stringWithCString:(const char*)xmlTextReaderConstName(reader) encoding:NSUTF8StringEncoding];
                    NSString *attrValue = [NSString stringWithCString:(const char*)xmlTextReaderConstValue(reader) encoding:NSUTF8StringEncoding];
                    //名前空間の指定があれば名前空間を指定する
                    if([attrName hasPrefix:@"xmlns"]) {
                        NSRange colon = [attrName rangeOfString:@":"];
                        if (colon.location != NSNotFound) {
                            NSString *prefix = [attrName substringFromIndex:colon.location + 1];
                            [dictionary setObject:attrValue forKey:prefix];
                        } else {
                            if (target.parent == nil) {
                                [dictionary setObject:attrValue forKey:@""];
                            }
                            target.name.nameSpaceName = attrValue;
                        }
                    }
                    [target add:[LQXAttribute attribute:attrName value:attrValue], nil];
                    ret = xmlTextReaderMoveToNextAttribute(reader);
                }
            }
            NSRange colon = [name rangeOfString:@":"];
            
            if (colon.location != NSNotFound) {
                NSString *prefix = [name substringToIndex:colon.location];
                NSString *nameSpace = [dictionary objectForKey:prefix];
                if (nameSpace != nil) {
                    target.name.nameSpaceName = nameSpace;
                }
            } else {
                NSString *nameSpace = [dictionary objectForKey:@""];
                if (nameSpace != nil) {
                    target.name.nameSpaceName = nameSpace;
                }
            }

            if (isEmpty) {
                target = target.parent;
            }
            break;
        case XML_READER_TYPE_TEXT:
            if (1 == xmlTextReaderHasValue(reader)) {
                value = [NSString stringWithCString:(const char*)xmlTextReaderConstValue(reader) encoding:NSUTF8StringEncoding];
                target.value = value;
            }
            break;
        case XML_READER_TYPE_COMMENT: {
            if (1 == xmlTextReaderHasValue(reader)) {
                value = [NSString stringWithCString:(const char*)xmlTextReaderConstValue(reader) encoding:NSUTF8StringEncoding];
                LQXComment *newTarget = [LQXComment comment:value];
                [target add:newTarget, nil];
            }
        } break;
        case XML_READER_TYPE_END_ELEMENT:
            //親が無い＝ルート要素なのでチェックする
            if (target.parent != nil) {
                target = target.parent;
            }
            break;
        case XML_READER_TYPE_XML_DECLARATION:
        case XML_READER_TYPE_DOCUMENT:
        case XML_READER_TYPE_ATTRIBUTE:
        case XML_READER_TYPE_CDATA:
        case XML_READER_TYPE_ENTITY_REFERENCE:
        case XML_READER_TYPE_ENTITY:
        case XML_READER_TYPE_PROCESSING_INSTRUCTION:
        case XML_READER_TYPE_DOCUMENT_TYPE:
        case XML_READER_TYPE_DOCUMENT_FRAGMENT:
        case XML_READER_TYPE_NOTATION:
        case XML_READER_TYPE_WHITESPACE:
        case XML_READER_TYPE_SIGNIFICANT_WHITESPACE:
        case XML_READER_TYPE_END_ENTITY:
        default:
            break;
    }
    return target;
}

-(LQXElement*)initWithElement:(LQXElement*)element {
    if ((self = [super init])) {
        self.name = [[LQXName alloc]init];
        self.attributeArray = [element.attributeArray.objectEnumerator toMutableArray];
        self.nodeArray = [element.nodeArray.objectEnumerator toMutableArray];
    }
    return self;
}
-(LQXElement*)init:(NSString*)name {
    if ((self = [super init])) {
        self.name = [LQXName name:name];
        self.attributeArray = [[NSMutableArray alloc]init];
        self.nodeArray = [[NSMutableArray alloc]init];
    }
    return self;
}
-(LQXElement*)initWithXName:(LQXName*)name {
    if ((self = [super init])) {
        self.name = name;
        self.attributeArray = [[NSMutableArray alloc]init];
        self.nodeArray = [[NSMutableArray alloc]init];
    }
    return self;
}

-(LQXElement*)init:(NSString*)name value:(NSString*)value {
    if ((self = [super init])) {
        self.name = [LQXName name:name];
        self.value = value;
        self.attributeArray = [[NSMutableArray alloc]init];
        self.nodeArray = [[NSMutableArray alloc]init];
    }
    return self;
}
-(LQXElement*)initWithXName:(LQXName*)name value:(NSString*)value {
    if ((self = [super init])) {
        self.name = name;
        self.value = value;
        self.attributeArray = [[NSMutableArray alloc]init];
        self.nodeArray = [[NSMutableArray alloc]init];
    }
    return self;
}

-(LQXElement*)init:(NSString*)name objects:(id)firstObject, ... {
    va_list list;
    if ((self = [super init])) {
        self.name = [LQXName name:name];
        self.attributeArray = [[NSMutableArray alloc]init];
        self.nodeArray = [[NSMutableArray alloc]init];
        va_start(list, firstObject);
        [self addObject:firstObject];
        id object;
        while((object = va_arg(list, id))) {
            [self addObject:object];
        }
        va_end(list);
    }
    return self;
}
-(LQXElement*)initWithXName:(LQXName*)name objects:(id)firstObject, ... {
    va_list list;
    if ((self = [super init])) {
        self.name = name;
        self.attributeArray = [[NSMutableArray alloc]init];
        self.nodeArray = [[NSMutableArray alloc]init];
        va_start(list, firstObject);
        [self addObject:firstObject];
        id object;
        while((object = va_arg(list, id))) {
            [self addObject:object];
        }
        va_end(list);
    }
    return self;
}

-(void)addObject:(id)object {
    if (object == nil) {
        // 何もしない
    } else if ([object isKindOfClass:[LQXObject class]]) {
        LQXObject *xObject = object;
        xObject.parent = self;
        xObject.document = self.document;
        switch (xObject.nodeType) {
            case XmlNodeTypeAttribute:
                [self.attributeArray addObject:xObject];
                break;
            case XmlNodeTypeComment:
            case XmlNodeTypeElement:
                [self.nodeArray addObject:xObject];
                break;
            default:
                break;
        }
    } else if ([object isKindOfClass:[NSArray class]]) {
        for (id item in object) {
            [self addObject:item];
        }
    } else if ([object isKindOfClass:[NSString class]]) {
        LQXElement *xElement = [LQXElement elementWithXName:[LQXName name:object]];
        xElement.parent = self;
        xElement.document = self.document;
        [self.nodeArray addObject:xElement];
    }
}

-(LQXAttribute*)attribute:(NSString*)name {
    return [self.attributeArray.objectEnumerator singleOrNil:^BOOL(id item) {
        LQXAttribute *attribute = item;
        return [[attribute.name toString] isEqualToString:name];
    }];
}

-(LQXAttribute*)attributeWithName:(LQXName*)name {
    return [self.attributeArray.objectEnumerator singleOrNil:^BOOL(id item) {
        LQXAttribute *attribute = item;
        return [[attribute.name toString] isEqualToString:[name toString]];
    }];
}
-(NSEnumerator*)attributes {
    return self.attributeArray.objectEnumerator;
}

-(NSEnumerator*)attributes:(NSString*)name {
    return [self.attributeArray.objectEnumerator where:^BOOL(id item) {
        LQXAttribute *attribute = item;
        return [[attribute.name toString] isEqualToString:name];
    }];
}

-(NSEnumerator*)attributesWithName:(LQXName*)name {
    return [self.attributeArray.objectEnumerator where:^BOOL(id item) {
        LQXAttribute *attribute = item;
        return [[attribute.name toString] isEqualToString:[name toString]];
    }];
}
-(void)removeAll {
    self.attributeArray = [[NSMutableArray alloc]init];
    self.nodeArray = [[NSMutableArray alloc]init];
}
-(void)removeAttributes {
    self.attributeArray = [[NSMutableArray alloc]init];
}

-(void)setAttribute:(NSString*)name value:(NSString*)value {
    if (value == nil) {
        [self.attributeArray removeObject:[self.attributeArray.objectEnumerator firstOrNil:^BOOL(id item) {
            return [[((LQXAttribute*)item).name toString] isEqualToString:name];
        }]];
    } else {
        [self.attributeArray addObject:[LQXAttribute attribute:name value:value]];
    }
}

-(void)setAttributeWithName:(LQXName*)name value:(NSString*)value {
    if (value == nil) {
        [self.attributeArray removeObject:[self.attributeArray.objectEnumerator firstOrNil:^BOOL(id item) {
            return [[((LQXAttribute*)item).name toString] isEqualToString:[name toString]];
        }]];
    } else {
        [self.attributeArray addObject:[LQXAttribute attributeWithXName:name value:value]];
    }
}

-(void)setElement:(NSString*)name value:(NSString*)value {
    if (value == nil) {
        [self.nodeArray removeObject:[self.nodeArray.objectEnumerator firstOrNil:^BOOL(id item) {
            return [[((LQXElement*)item).name toString] isEqualToString:name];
        }]];
    } else {
        [self.nodeArray addObject:[LQXElement element:name value:value]];
    }
}

-(void)setElementWithName:(LQXName*)name value:(NSString*)value {
    if (value == nil) {
        [self.nodeArray removeObject:[self.nodeArray.objectEnumerator firstOrNil:^BOOL(id item) {
            return [[((LQXElement*)item).name toString] isEqualToString:[name toString]];
        }]];
    } else {
        [self.nodeArray addObject:[[LQXElement alloc]initWithXName:name value:value]];
    }
}

-(NSString *)description {
    NSInteger depth = 0;
    NSMutableArray *nameSpaces = [[NSMutableArray alloc]init];
    if (self.document != nil && self.document.root != nil && ![self.document.root.name.nameSpaceName isEqualToString:@""]) {
        [nameSpaces addObject:self.document.root.name.nameSpaceName];
    }
    return [self descriptionCore:depth nameSpaces:nameSpaces];
}
-(NSString *)descriptionCore:(NSInteger)depth nameSpaces:(NSMutableArray*)nameSpaces {
    NSMutableString *result;
    
    NSMutableString *space = [NSMutableString stringWithString:@""];
    [[NSEnumerator repeat:@"  " count:depth]forEach:^(id item) {
        [space appendString:item];
    }];
    result = [NSMutableString stringWithFormat:@"%@<%@",space, [self.name toString]];
    //result = [NSMutableString stringWithFormat:@"%@<%@",space, self.name.localName];
    if (self.hasAttributes) {
        for (LQXAttribute *attr in self.attributes) {
            [result appendString:[attr description]];
        }
    }
    if (self.isEmpty) {
        [result appendString:@" />\n"];
    } else if (self.hasValue) {
        [result appendFormat:@">%@</%@>\n",self.value, [self.name toString]];
        //[result appendFormat:@">%@</%@>\n",self.value, self.name.localName];
    } else {
        [result appendString:@">\n"];
        for (id elem in self.nodeArray) {
            if ([elem isKindOfClass:[LQXElement class]]) {
                [result appendString:[elem descriptionCore:depth + 1 nameSpaces:nameSpaces]];
            } else {
                [result appendFormat:@"  %@%@",space,[elem description]];
            }
        }
        [result appendFormat:@"%@</%@>\n",space, [self.name toString]];
        //[result appendFormat:@"%@</%@>\n",space, self.name.localName];
    }
    return result;
}
@end

#pragma mark LQXDocument

@implementation LQXDocument

@dynamic root;
-(LQXElement *)root {
    return [self.elements firstOrNil];
}

@dynamic nodeType;
-(XmlNodeType)nodeType {
    return XmlNodeTypeDocument;
}

+(LQXDocument*)document {
    return [[LQXDocument alloc]init];
}
+(LQXDocument*)documentWithDocument:(LQXDocument*)document {
    return [[LQXDocument alloc]initWithDocument:document];
}
+(LQXDocument*)documentWithObject:(id)firstObject, ... {
    LQXDocument *document = [LQXDocument document];
    va_list list;
    va_start(list, firstObject);
    [document addObject:firstObject];
    id object;
    while((object = va_arg(list, id))) {
        [document addObject:object];
    }
    va_end(list);
    return document;
}
+(LQXDocument*)documentWithDeclaration:(LQXDeclaration*)declaration objects:(id)firstObject, ... {
    LQXDocument *document = [LQXDocument document];
    document.declaration = declaration;
    va_list list;
    va_start(list, firstObject);
    [document addObject:firstObject];
    id object;
    while((object = va_arg(list, id))) {
        [document addObject:object];
    }
    va_end(list);
    return document;
}

+(LQXDocument*)load:(NSString*)path {
    LQXDocument *result = [LQXDocument document];
    LQXElement *element;
    int ret;
    xmlTextReaderPtr  reader;
    const char *input_file = [path cStringUsingEncoding:NSUTF8StringEncoding];
    reader = xmlReaderForFile(input_file, NULL, 0);
    if (NULL == reader) {
        fprintf(stderr, "Failed to parse %s\n", input_file);
        return nil;
    }
    
    NSMutableDictionary *nameSpaces = [[NSMutableDictionary alloc]init];

    /* Parse XML */
    while (1 == (ret = xmlTextReaderRead(reader))) {
        element = [LQXElement processNode:reader target:element nameSpaces:nameSpaces];
    }
    
    if (0 != ret) {
        fprintf(stderr, "%s : failed to parse\n", input_file);
    }
    
    /* Free reader */
    xmlFreeTextReader(reader);
    
    xmlCleanupParser();
    
    [result addObject:element];
    return result;
}

-(LQXDocument*)init {
    self.nodeArray = [[NSMutableArray alloc]init];
    if ((self = [super init])) {
        self.declaration = [LQXDeclaration declareWithEncoding:NSUTF8StringEncoding version:@"1.0"];
        [self addObject:@"Root"];
    }
    return self;
}
-(LQXDocument*)initWithDocument:(LQXDocument*)document {
    self.nodeArray = [[NSMutableArray alloc]init];
    if ((self = [super init])) {
        self.declaration = document.declaration;
        [self addObject:document.root];
    }
    return self;
}
-(LQXDocument*)initWithObjects:(id)firstObject, ... {
    self.nodeArray = [[NSMutableArray alloc]init];
    va_list list;
    if ((self = [super init])) {
        self.declaration = [LQXDeclaration declareWithEncoding:NSUTF8StringEncoding version:@"1.0"];
        [self addObject:firstObject];
        va_start(list, firstObject);
        id object;
        while((object = va_arg(list, id))) {
            [self addObject:object];
        }
        va_end(list);
    }
    return self;
}
-(LQXDocument*)initWithDeclaration:(LQXDeclaration*)declaration objects:(id)firstObject, ... {
    self.nodeArray = [[NSMutableArray alloc]init];
    va_list list;
    if ((self = [super init])) {
        self.declaration = declaration;
        [self addObject:firstObject];
        va_start(list, firstObject);
        id object;
        while((object = va_arg(list, id))) {
            [self addObject:object];
        }
        va_end(list);
    }
    return self;
}

-(void)addObject:(id)object {
    if (object == nil) {
        // 何もしない
    } else if ([object isKindOfClass:[LQXElement class]]) {
        NSArray *elements = [self.elements toArray];
        if (elements.count != 0) {
            for (id obj in elements) {
                [self.nodeArray removeObject:obj];
            }
        }
        [self.nodeArray addObject:object];
    } else if ([object isKindOfClass:[NSString class]]) {
        NSArray *elements = [self.elements toArray];
        if (elements.count != 0) {
            for (id obj in elements) {
                [self.nodeArray removeObject:obj];
            }
        }
        [self.nodeArray addObject:[LQXElement element:object]];
    }
}

-(NSString *)description {
    NSMutableString *result = [NSMutableString stringWithString:[self.declaration description]];
    LQXElement *root = self.root;
    if (root != nil) {
        [result appendString:[self.root description]];
    }
    return result;
}

@end

