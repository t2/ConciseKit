#import "NSArray+ConciseKit.h"

@implementation NSArray (ConciseKit)

- (id)$first {
  return [self objectAtIndex:0];
}

- (NSArray *)$first:(int)n {
  NSRange range = NSMakeRange(0, (NSUInteger)n);
  return [self subarrayWithRange:range];
}

- (id)$last {
  return [self lastObject];
}

- (BOOL)$all:(BOOL (^)(id))block {
  return [self count] == [[self $select:block] count];
}

- (BOOL)$any:(BOOL (^)(id))block {
  return [[self $select:block] count] > 0;
}

- (id)$at:(NSUInteger)index {
  return [self objectAtIndex:index];
}

- (NSArray *)$compact {
    NSMutableArray *backingArray = [NSMutableArray arrayWithArray:self];
    [backingArray removeObjectIdenticalTo:[NSNull null]];
    return [NSArray arrayWithArray:backingArray];
}

- (NSArray *)$concat:(NSArray *)otherArray {
  NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self];
  [mutableArray addObjectsFromArray:otherArray];
  return [NSArray arrayWithArray:mutableArray];
}


- (NSArray *)$each:(void (^)(id obj))block {
  [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    block(obj);
  }];
  return self;
}

- (NSArray *)$eachWithIndex:(void (^)(id obj, NSUInteger idx))block {
  [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    block(obj, idx);
  }];
  return self;
}

- (NSArray *)$eachWithStop:(void (^)(id obj, BOOL *stop))block {
  [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    block(obj, stop);
  }];
  return self;
}

- (NSArray *)$eachWithIndexAndStop:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
  [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    block(obj, idx, stop);
  }];
  return self;
}

- (BOOL)$empty {
  return [self count] == 0;
}

- (BOOL)$include:(id)someObj {
  NSIndexSet *indexes = [self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    return obj == someObj;
  }];
  
  return [indexes count] > 0;
}

- (NSArray *)$map:(id (^)(id obj))block {
  __block NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
  [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [array addObject:block(obj)];
  }];
  return array;
}

- (NSArray *)$mapWithIndex:(id (^)(id obj, NSUInteger idx))block {
  __block NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
  [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [array addObject:block(obj, idx)];
  }];
  return array;
}

- (id)$reduce:(id (^)(id memo, id obj))block {
  __block id ret = nil;
  [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    if (idx == 0) {
      ret = obj;
    } else {
      ret = block(ret, obj);
    }
  }];
  return ret;
}

- (id)$reduceStartingAt:(id)starting with:(id (^)(id memo, id obj))block {
  __block id ret = starting;
  [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    ret = block(ret, obj);
  }];
  return ret;
}

- (NSArray *)$reverse {
  return [[self reverseObjectEnumerator] allObjects];
}

- (NSArray *)$select:(BOOL(^)(id obj))block {
  __block NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
  [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    if (block(obj)) {
      [array addObject:obj];
    }
  }];
  return [NSArray arrayWithArray:array];
}

- (id)$detect:(BOOL(^)(id obj))block {
  __block id ret = nil;
  [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    if (block(obj)) {
      *stop = YES;
      ret = obj;
    }
  }];
  return ret;
}

- (NSString *)$join {
  return [self componentsJoinedByString:@""];
}

- (NSString *)$join:(NSString *)separator {
  return [self componentsJoinedByString:separator];
}

@end

@implementation NSMutableArray (ConciseKit)

#ifndef __has_feature
    #define __has_feature(x) 0
#endif
#if __has_feature(objc_arc)
    #define IF_ARC(with, without) with
#else
    #define IF_ARC(with, without) without
#endif

- (NSMutableArray *)$drop:(int)n {
  if (n < 1)
    return self;
  
  NSRange dropRange = NSMakeRange(0, n);
  NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self];
  [mutableArray removeObjectsInRange:dropRange];
  
  return mutableArray;
}

- (NSMutableArray *)$push:(id)anObject {
  [self addObject:anObject];
  return self;
}

- (id)$pop; {
    IF_ARC(id lastObject = [self lastObject];, id lastObject = [[[self lastObject] retain] autorelease];)
    [self removeLastObject];
    return lastObject;
}

- (NSArray *)$replace:(NSArray *)otherArray {
  [self removeAllObjects];
  [self addObjectsFromArray:otherArray];
  return self;
}

- (id)$shift; {
    IF_ARC(id firstObject = [self objectAtIndex:0];, id firstObject = [[[self objectAtIndex:0] retain] autorelease];)
    
    [self removeObjectAtIndex:0];
    return firstObject;
}

- (NSMutableArray *)$unshift:(id)anObject {
  [self insertObject:anObject atIndex:0];
  return self;
}

@end