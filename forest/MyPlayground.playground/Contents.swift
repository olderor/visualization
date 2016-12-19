//: Playground - noun: a place where people can play
import Foundation

let DequeOverAllocateFactor = 2
let DequeDownsizeTriggerFactor = 16
let DequeDefaultMinimumCapacity = 0

/// This is a basic "circular-buffer" style Double-Ended Queue.
public struct Deque<T>: RandomAccessCollection, RangeReplaceableCollection, ExpressibleByArrayLiteral, CustomDebugStringConvertible {
    public typealias Index = Int
    public typealias Indices = CountableRange<Int>
    public typealias Element = T
    
    var buffer: DequeBuffer<T>? = nil
    let minCapacity: Int
    
    /// Implementation of RangeReplaceableCollection function
    public init() {
        self.minCapacity = DequeDefaultMinimumCapacity
    }
    
    /// Allocate with a minimum capacity
    public init(minCapacity: Int) {
        self.minCapacity = minCapacity
    }
    
    /// Implementation of ExpressibleByArrayLiteral function
    public init(arrayLiteral: T...) {
        self.minCapacity = DequeDefaultMinimumCapacity
        replaceSubrange(0..<0, with: arrayLiteral)
    }
    
    /// Implementation of CustomDebugStringConvertible function
    public var debugDescription: String {
        var result = "\(type(of: self))(["
        var iterator = makeIterator()
        if let next = iterator.next() {
            debugPrint(next, terminator: "", to: &result)
            while let n = iterator.next() {
                result += ", "
                debugPrint(n, terminator: "", to: &result)
            }
        }
        result += "])"
        return result
    }
    
    public subscript(bounds: Range<Index>) -> RangeReplaceableRandomAccessSlice<Deque<T>> {
        return RangeReplaceableRandomAccessSlice<Deque<T>>(base: self, bounds: bounds)
    }
    
    /// Implementation of RandomAccessCollection function
    public subscript(_ at: Index) -> T {
        get {
            if let b = buffer {
                precondition(at < b.unsafeHeader.pointee.count)
                var offset = b.unsafeHeader.pointee.offset + at
                if offset >= b.unsafeHeader.pointee.capacity {
                    offset -= b.unsafeHeader.pointee.capacity
                }
                return b.unsafeElements[offset]
            } else {
                preconditionFailure("Index beyond end of queue")
            }
        }
    }
    
    /// Implementation of Collection function
    public var startIndex: Index {
        return 0
    }
    
    /// Implementation of Collection function
    public var endIndex: Index {
        if let b = buffer {
            return b.unsafeHeader.pointee.count
        }
        
        return 0
    }
    
    /// Implementation of Collection function
    public var isEmpty: Bool {
        if let b = buffer {
            return b.unsafeHeader.pointee.count == 0
        }
        
        return true
    }
    
    /// Implementation of Collection function
    public var count: Int {
        return endIndex
    }
    
    /// Optimized implementation of RangeReplaceableCollection function
    public mutating func append(_ newElement: T) {
        if let b = buffer {
            if b.unsafeHeader.pointee.capacity >= b.unsafeHeader.pointee.count + 1 {
                var index = b.unsafeHeader.pointee.offset + b.unsafeHeader.pointee.count
                if index >= b.unsafeHeader.pointee.capacity {
                    index -= b.unsafeHeader.pointee.capacity
                }
                b.unsafeElements.advanced(by: index).initialize(to: newElement)
                b.unsafeHeader.pointee.count += 1
                return
            }
        }
        
        let index = endIndex
        return replaceSubrange(index..<index, with: CollectionOfOne(newElement))
    }
    
    /// Optimized implementation of RangeReplaceableCollection function
    public mutating func prepend(_ newElement: T) {
        var index = startIndex
        if let b = buffer {
            if b.unsafeHeader.pointee.capacity >= b.unsafeHeader.pointee.count + 1 {
                let index = (b.unsafeHeader.pointee.offset - 1 + b.unsafeHeader.pointee.capacity) % b.unsafeHeader.pointee.capacity
                b.unsafeElements.advanced(by: index).initialize(to: newElement)
                b.unsafeHeader.pointee.count += 1
                b.unsafeHeader.pointee.offset = index
                return
            }
            index = 0
        }
        return replaceSubrange(index..<index, with: CollectionOfOne(newElement))
    }
    
    /// Optimized implementation of RangeReplaceableCollection function
    public mutating func insert(_ newElement: T, at: Int) {
        if let b = buffer {
            if at == 0, b.unsafeHeader.pointee.capacity >= b.unsafeHeader.pointee.count + 1 {
                var index = b.unsafeHeader.pointee.offset - 1
                if index < 0 {
                    index += b.unsafeHeader.pointee.capacity
                }
                b.unsafeElements.advanced(by: index).initialize(to: newElement)
                b.unsafeHeader.pointee.count += 1
                b.unsafeHeader.pointee.offset = index
                return
            }
        }
        
        return replaceSubrange(at..<at, with: CollectionOfOne(newElement))
    }
    
    /// Optimized implementation of RangeReplaceableCollection function
    public mutating func remove(at: Int) {
        if let b = buffer {
            if at == b.unsafeHeader.pointee.count - 1 {
                b.unsafeHeader.pointee.count -= 1
                return
            } else if at == 0, b.unsafeHeader.pointee.count > 0 {
                b.unsafeHeader.pointee.offset += 1
                if b.unsafeHeader.pointee.offset >= b.unsafeHeader.pointee.capacity {
                    b.unsafeHeader.pointee.offset -= b.unsafeHeader.pointee.capacity
                }
                b.unsafeHeader.pointee.count -= 1
                return
            }
        }
        
        return replaceSubrange(at...at, with: EmptyCollection())
    }
    
    /// Optimized implementation of RangeReplaceableCollection function
    public mutating func removeFirst() -> T {
        if let b = buffer {
            precondition(b.unsafeHeader.pointee.count > 0, "Index beyond bounds")
            let result = b.unsafeElements[b.unsafeHeader.pointee.offset]
            b.unsafeElements.advanced(by: b.unsafeHeader.pointee.offset).deinitialize()
            b.unsafeHeader.pointee.offset += 1
            if b.unsafeHeader.pointee.offset >= b.unsafeHeader.pointee.capacity {
                b.unsafeHeader.pointee.offset -= b.unsafeHeader.pointee.capacity
            }
            b.unsafeHeader.pointee.count -= 1
            return result
        }
        preconditionFailure("Index beyond bounds")
    }
    
    // Used when removing a range from the collection or deiniting self.
    fileprivate static func deinitialize(range: CountableRange<Int>, header: UnsafeMutablePointer<DequeHeader>, body: UnsafeMutablePointer<T>) {
        let splitRange = Deque.mapIndices(inRange: range, header: header)
        body.advanced(by: splitRange.low.startIndex).deinitialize(count: splitRange.low.count)
        body.advanced(by: splitRange.high.startIndex).deinitialize(count: splitRange.high.count)
    }
    
    // Move from an initialized to an uninitialized location, deinitializing the source.
    //
    // NOTE: the terms "preMapped" and "postMapped" are used. "preMapped" refer to the public indices exposed by this type (zero based, contiguous), and "postMapped" refers to internal offsets within the buffer (not necessarily zero based and may wrap around). This function will only handle a single, contiguous block of "postMapped" indices so the caller must ensure that this function is invoked separately for each contiguous block.
    fileprivate static func moveInitialize(preMappedSourceRange: CountableRange<Int>, postMappedDestinationRange: CountableRange<Int>, sourceHeader: UnsafeMutablePointer<DequeHeader>, sourceBody: UnsafeMutablePointer<T>, destinationBody: UnsafeMutablePointer<T>) {
        let sourceSplitRange = Deque.mapIndices(inRange: preMappedSourceRange, header: sourceHeader)
        
        assert(sourceSplitRange.low.startIndex >= 0 && (sourceSplitRange.low.startIndex < sourceHeader.pointee.capacity || sourceSplitRange.low.startIndex == sourceSplitRange.low.endIndex))
        assert(sourceSplitRange.low.endIndex >= 0 && sourceSplitRange.low.endIndex <= sourceHeader.pointee.capacity)
        
        assert(sourceSplitRange.high.startIndex >= 0 && (sourceSplitRange.high.startIndex < sourceHeader.pointee.capacity || sourceSplitRange.high.startIndex == sourceSplitRange.high.endIndex))
        assert(sourceSplitRange.high.endIndex >= 0 && sourceSplitRange.high.endIndex <= sourceHeader.pointee.capacity)
        
        destinationBody.advanced(by: postMappedDestinationRange.startIndex).moveInitialize(from: sourceBody.advanced(by: sourceSplitRange.low.startIndex), count: sourceSplitRange.low.count)
        destinationBody.advanced(by: postMappedDestinationRange.startIndex + sourceSplitRange.low.count).moveInitialize(from: sourceBody.advanced(by: sourceSplitRange.high.startIndex), count: sourceSplitRange.high.count)
    }
    
    // Copy from an initialized to an uninitialized location, leaving the source initialized.
    //
    // NOTE: the terms "preMapped" and "postMapped" are used. "preMapped" refer to the public indices exposed by this type (zero based, contiguous), and "postMapped" refers to internal offsets within the buffer (not necessarily zero based and may wrap around). This function will only handle a single, contiguous block of "postMapped" indices so the caller must ensure that this function is invoked separately for each contiguous block.
    fileprivate static func copyInitialize(preMappedSourceRange: CountableRange<Int>, postMappedDestinationRange: CountableRange<Int>, sourceHeader: UnsafeMutablePointer<DequeHeader>, sourceBody: UnsafeMutablePointer<T>, destinationBody: UnsafeMutablePointer<T>) {
        let sourceSplitRange = Deque.mapIndices(inRange: preMappedSourceRange, header: sourceHeader)
        
        assert(sourceSplitRange.low.startIndex >= 0 && (sourceSplitRange.low.startIndex < sourceHeader.pointee.capacity || sourceSplitRange.low.startIndex == sourceSplitRange.low.endIndex))
        assert(sourceSplitRange.low.endIndex >= 0 && sourceSplitRange.low.endIndex <= sourceHeader.pointee.capacity)
        
        assert(sourceSplitRange.high.startIndex >= 0 && (sourceSplitRange.high.startIndex < sourceHeader.pointee.capacity || sourceSplitRange.high.startIndex == sourceSplitRange.high.endIndex))
        assert(sourceSplitRange.high.endIndex >= 0 && sourceSplitRange.high.endIndex <= sourceHeader.pointee.capacity)
        
        destinationBody.advanced(by: postMappedDestinationRange.startIndex).initialize(from: sourceBody.advanced(by: sourceSplitRange.low.startIndex), count: sourceSplitRange.low.count)
        destinationBody.advanced(by: postMappedDestinationRange.startIndex + sourceSplitRange.low.count).initialize(from: sourceBody.advanced(by: sourceSplitRange.high.startIndex), count: sourceSplitRange.high.count)
    }
    
    // Translate from preMapped to postMapped indices.
    //
    // "preMapped" refer to the public indices exposed by this type (zero based, contiguous), and "postMapped" refers to internal offsets within the buffer (not necessarily zero based and may wrap around).
    //
    // Since "postMapped" indices are not necessarily contiguous, two separate, contiguous ranges are returned. Both `startIndex` and `endIndex` in the `high` range will equal the `endIndex` in the `low` range if the range specified by `inRange` is continuous after mapping.
    fileprivate static func mapIndices(inRange: CountableRange<Int>, header: UnsafeMutablePointer<DequeHeader>) -> (low: CountableRange<Int>, high: CountableRange<Int>) {
        let limit = header.pointee.capacity - header.pointee.offset
        if inRange.startIndex >= limit {
            return (low: (inRange.startIndex - limit)..<(inRange.endIndex - limit), high: (inRange.endIndex - limit)..<(inRange.endIndex - limit))
        } else if inRange.endIndex > limit {
            return (low: (inRange.startIndex + header.pointee.offset)..<header.pointee.capacity, high: 0..<(inRange.endIndex - limit))
        }
        return (low: (inRange.startIndex + header.pointee.offset)..<(inRange.endIndex + header.pointee.offset), high: (inRange.endIndex + header.pointee.offset)..<(inRange.endIndex + header.pointee.offset))
    }
    
    // Internal implementation of replaceSubrange<C>(_:with:) when no reallocation
    // of the underlying buffer is required
    private static func mutateWithoutReallocate<C>(info: DequeMutationInfo, elements newElements: C, header: UnsafeMutablePointer<DequeHeader>, body: UnsafeMutablePointer<T>) where C: Collection, C.Iterator.Element == T {
        if info.removed > 0 {
            Deque.deinitialize(range: info.start..<(info.start + info.removed), header: header, body: body)
        }
        
        if info.removed != info.inserted {
            if info.start < header.pointee.count - (info.start + info.removed) {
                let oldOffset = header.pointee.offset
                header.pointee.offset -= info.inserted - info.removed
                if header.pointee.offset < 0 {
                    header.pointee.offset += header.pointee.capacity
                } else if header.pointee.offset >= header.pointee.capacity {
                    header.pointee.offset -= header.pointee.capacity
                }
                let delta = oldOffset - header.pointee.offset
                if info.start != 0 {
                    let destinationSplitIndices = Deque.mapIndices(inRange: 0..<info.start, header: header)
                    let lowCount = destinationSplitIndices.low.count
                    Deque.moveInitialize(preMappedSourceRange: delta..<(delta + lowCount), postMappedDestinationRange: destinationSplitIndices.low, sourceHeader: header, sourceBody: body, destinationBody: body)
                    if lowCount != info.start {
                        Deque.moveInitialize(preMappedSourceRange: (delta + lowCount)..<(info.start + delta), postMappedDestinationRange: destinationSplitIndices.high, sourceHeader: header, sourceBody: body, destinationBody: body)
                    }
                }
            } else {
                if (info.start + info.removed) != header.pointee.count {
                    let start = info.start + info.inserted
                    let end = header.pointee.count - info.removed + info.inserted
                    let destinationSplitIndices = Deque.mapIndices(inRange: start..<end, header: header)
                    let lowCount = destinationSplitIndices.low.count
                    Deque.moveInitialize(preMappedSourceRange: start..<(start + lowCount), postMappedDestinationRange: destinationSplitIndices.low, sourceHeader: header, sourceBody: body, destinationBody: body)
                    if lowCount != end - start {
                        Deque.moveInitialize(preMappedSourceRange: (start + lowCount)..<header.pointee.count, postMappedDestinationRange: destinationSplitIndices.high, sourceHeader: header, sourceBody: body, destinationBody: body)
                    }
                }
            }
            header.pointee.count = header.pointee.count - info.removed + info.inserted
        }
        
        if info.inserted == 1, let e = newElements.first {
            if info.start >= header.pointee.capacity - header.pointee.offset {
                body.advanced(by: info.start - header.pointee.capacity + header.pointee.offset).initialize(to: e)
            } else {
                body.advanced(by: header.pointee.offset + info.start).initialize(to: e)
            }
        } else if info.inserted > 0 {
            let inserted = Deque.mapIndices(inRange: info.start..<(info.start + info.inserted), header: header)
            var iterator = newElements.makeIterator()
            for i in inserted.low {
                if let n = iterator.next() {
                    body.advanced(by: i).initialize(to: n)
                }
            }
            for i in inserted.high {
                if let n = iterator.next() {
                    body.advanced(by: i).initialize(to: n)
                }
            }
        }
    }
    
    // Internal implementation of replaceSubrange<C>(_:with:) when reallocation
    // of the underlying buffer is required. Can handle no previous buffer or
    // previous buffer too small or previous buffer too big or previous buffer
    // non-unique.
    private mutating func reallocateAndMutate<C>(info: DequeMutationInfo, elements newElements: C, header: UnsafeMutablePointer<DequeHeader>?, body: UnsafeMutablePointer<T>?, deletePrevious: Bool) where C: Collection, C.Iterator.Element == T {
        if info.newCount == 0 {
            // Let the regular deallocation handle the deinitialize
            buffer = nil
        } else {
            let newCapacity: Int
            let oldCapacity = header?.pointee.capacity ?? 0
            if info.newCount > oldCapacity || info.newCount <= oldCapacity / DequeDownsizeTriggerFactor {
                newCapacity = Swift.max(minCapacity, info.newCount * DequeOverAllocateFactor)
            } else {
                newCapacity = oldCapacity
            }
            
            let newBuffer = DequeBuffer<T>.create(capacity: newCapacity, count: info.newCount)
            if let headerPtr = header, let bodyPtr = body {
                if deletePrevious, info.removed > 0 {
                    Deque.deinitialize(range: info.start..<(info.start + info.removed), header: headerPtr, body: bodyPtr)
                }
                
                let newBody = newBuffer.unsafeElements
                if info.start != 0 {
                    if deletePrevious {
                        Deque.moveInitialize(preMappedSourceRange: 0..<info.start, postMappedDestinationRange: 0..<info.start, sourceHeader: headerPtr, sourceBody: bodyPtr, destinationBody: newBody)
                    } else {
                        Deque.copyInitialize(preMappedSourceRange: 0..<info.start, postMappedDestinationRange: 0..<info.start, sourceHeader: headerPtr, sourceBody: bodyPtr, destinationBody: newBody)
                    }
                }
                
                let oldCount = header?.pointee.count ?? 0
                if info.start + info.removed != oldCount {
                    if deletePrevious {
                        Deque.moveInitialize(preMappedSourceRange: (info.start + info.removed)..<oldCount, postMappedDestinationRange: (info.start + info.inserted)..<info.newCount, sourceHeader: headerPtr, sourceBody: bodyPtr, destinationBody: newBody)
                    } else {
                        Deque.copyInitialize(preMappedSourceRange: (info.start + info.removed)..<oldCount, postMappedDestinationRange: (info.start + info.inserted)..<info.newCount, sourceHeader: headerPtr, sourceBody: bodyPtr, destinationBody: newBody)
                    }
                }
                
                // Make sure the old buffer doesn't deinitialize when it deallocates.
                if deletePrevious {
                    headerPtr.pointee.count = 0
                }
            }
            
            if info.inserted > 0 {
                // Insert the new subrange
                newBuffer.unsafeElements.advanced(by: info.start).initialize(from: newElements)
            }
            
            buffer = newBuffer
        }
    }
    
    /// Implemetation of the RangeReplaceableCollection function. Internally
    /// implemented using either mutateWithoutReallocate or reallocateAndMutate.
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C: Collection, C.Iterator.Element == T {
        precondition(subrange.lowerBound >= 0, "Subrange lowerBound is negative")
        
        if isKnownUniquelyReferenced(&buffer), let b = buffer {
            let (header, body) = (b.unsafeHeader, b.unsafeElements)
            let info = DequeMutationInfo(subrange: subrange, previousCount: header.pointee.count, insertedCount: numericCast(newElements.count))
            if info.newCount <= header.pointee.capacity && (info.newCount < minCapacity || info.newCount > header.pointee.capacity / DequeDownsizeTriggerFactor) {
                Deque.mutateWithoutReallocate(info: info, elements: newElements, header: header, body: body)
            } else {
                reallocateAndMutate(info: info, elements: newElements, header: header, body: body, deletePrevious: true)
            }
        } else if let b = buffer {
            let (header, body) = (b.unsafeHeader, b.unsafeElements)
            let info = DequeMutationInfo(subrange: subrange, previousCount: header.pointee.count, insertedCount: numericCast(newElements.count))
            reallocateAndMutate(info: info, elements: newElements, header: header, body: body, deletePrevious: false)
        } else {
            let info = DequeMutationInfo(subrange: subrange, previousCount: 0, insertedCount: numericCast(newElements.count))
            reallocateAndMutate(info: info, elements: newElements, header: nil, body: nil, deletePrevious: true)
        }
    }
}

// Internal state for the Deque
struct DequeHeader {
    var offset: Int
    var count: Int
    var capacity: Int
}

// Private type used to communicate parameters between replaceSubrange<C>(_:with:)
// and reallocateAndMutate or mutateWithoutReallocate
struct DequeMutationInfo {
    let start: Int
    let removed: Int
    let inserted: Int
    let newCount: Int
    
    init(subrange: Range<Int>, previousCount: Int, insertedCount: Int) {
        precondition(subrange.upperBound <= previousCount, "Subrange upperBound is out of range")
        
        self.start = subrange.lowerBound
        self.removed = subrange.count
        self.inserted = insertedCount
        self.newCount = previousCount - self.removed + self.inserted
    }
}

// An implementation of DequeBuffer using ManagedBufferPointer to allocate the
// storage and then using raw pointer offsets into self to access contents
// (avoiding the ManagedBufferPointer accessors which are a performance problem
// in Swift 3).
final class DequeBuffer<T> {
    typealias ValueType = T
    
    class func create(capacity: Int, count: Int) -> DequeBuffer<T> {
        let p = ManagedBufferPointer<DequeHeader, T>(bufferClass: self, minimumCapacity: capacity) { buffer, capacityFunction in
            DequeHeader(offset: 0, count: count, capacity: capacity)
        }
        
        let result = unsafeDowncast(p.buffer, to: DequeBuffer<T>.self)
        
        // We need to assert this in case some of our dirty assumptions stop being true
        assert(ManagedBufferPointer<DequeHeader, T>(unsafeBufferObject: result).withUnsafeMutablePointers { (header, body) in result.unsafeHeader == header && result.unsafeElements == body })
        
        return result
    }
    
    static var headerOffset: Int {
        return Int(roundUp(UInt(MemoryLayout<HeapObject>.size), toAlignment: MemoryLayout<DequeHeader>.alignment))
    }
    
    static var elementOffset: Int {
        return Int(roundUp(UInt(headerOffset) + UInt(MemoryLayout<DequeHeader>.size), toAlignment: MemoryLayout<T>.alignment))
    }
    
    var unsafeElements: UnsafeMutablePointer<T> {
        return Unmanaged<DequeBuffer<T>>.passUnretained(self).toOpaque().advanced(by: DequeBuffer<T>.elementOffset).assumingMemoryBound(to: T.self)
    }
    
    var unsafeHeader: UnsafeMutablePointer<DequeHeader> {
        return Unmanaged<DequeBuffer<T>>.passUnretained(self).toOpaque().advanced(by: DequeBuffer<T>.headerOffset).assumingMemoryBound(to: DequeHeader.self)
    }
    
    deinit {
        let h = unsafeHeader
        if h.pointee.count > 0 {
            Deque<T>.deinitialize(range: 0..<h.pointee.count, header: h, body: unsafeElements)
        }
    }
}

func roundUp(_ offset: UInt, toAlignment alignment: Int) -> UInt {
    let x = offset + UInt(bitPattern: alignment) &- 1
    return x & ~(UInt(bitPattern: alignment) &- 1)
}

struct HeapObject {
    let metadata: Int = 0
    let strongRefCount: UInt32 = 0
    let weakRefCount: UInt32 = 0
}


class HeapNode<Element> {
    public var order = 0
    public var childrens = Deque<HeapNode>()
    public var singletons = Deque<HeapNode>()
    public var value: Element
    
    init(value: Element) {
        self.value = value
    }
    
    init (value: Element, order: Int) {
        self.value = value
        self.order = order
    }
}

class SkewBinomialHeap<Element: Comparable> {
    
    private var trees = Deque<HeapNode<Element>>()
    private var elementsCount = 0
    
    init() {
        
    }
    
    var first: Element? {
        return trees[findMinIndex()].value
    }
    
    private func cloneTree(tree: HeapNode<Element>) -> HeapNode<Element> {
        
        let result = HeapNode(value: tree.value, order: tree.order)
        
        for child in tree.childrens {
            result.childrens.append(child)
        }
        
        for singleton in tree.singletons {
            result.singletons.append(singleton)
        }
        
        return result
    }
    
    init(other: SkewBinomialHeap<Element>) {
        for tree in other.trees {
            trees.append(cloneTree(tree: tree))
        }
        elementsCount = other.elementsCount
    }
    
    var isEmpty: Bool {
        return elementsCount == 0
    }
    
    var size: Int {
        return elementsCount
    }
    
    private func merge(
        first: HeapNode<Element>?,
        second: HeapNode<Element>?) -> HeapNode<Element>? {
        
        if first == nil {
            return second
        }
        if second == nil {
            return first
        }
        
        var first = first!
        var second = second!
        if second.value < first.value {
            swap(&first, &second)
        }
        first.childrens.append(second)
        first.order += 1
        return first
    }
    
    private func insertSingleton(singleton: HeapNode<Element>) {
        if !(trees.count >= 2 && trees[0].order == trees[1].order) {
            trees.prepend(singleton)
            return
        }
        let first = trees.removeFirst()
        let second = trees.removeFirst()
        
        let newTree = merge(first: first, second: second)!
        if singleton.value < newTree.value {
            swap(&singleton.value, &newTree.value)
        }
        
        newTree.singletons.append(singleton)
        trees.prepend(newTree)
    }
    
    func push(element: Element) {
        insertSingleton(singleton: HeapNode(value: element))
        elementsCount += 1
    }
    
    private func findMinIndex() -> Int {
        var index = 0
        for i in 1..<trees.count {
            if trees[i].value < trees[index].value {
                index = i
            }
        }
        return index
    }
    
    private func mergeHeaps(
        first: Deque<HeapNode<Element>>,
        second: Deque<HeapNode<Element>>) {
        var first = first
        var second = second
        var result = Deque<HeapNode<Element>>()
        while !first.isEmpty && !second.isEmpty {
            if first.first!.order < second.first!.order {
                result.append(first.removeFirst())
            } else {
                result.append(second.removeFirst())
            }
        }
        
        while !first.isEmpty {
            result.append(first.removeFirst())
        }
        while !second.isEmpty {
            result.append(second.removeFirst())
        }
        
        while !result.isEmpty {
            var treesWithSameOrder = Deque<HeapNode<Element>>()
            treesWithSameOrder.append(result.first!)
            let _ = result.removeFirst()
            
            while !result.isEmpty &&
                result.first!.order == treesWithSameOrder.first!.order {
                    treesWithSameOrder.append(result.first!)
                    let _ = result.removeFirst()
            }
            
            if treesWithSameOrder.count % 2 == 1 {
                first.append(treesWithSameOrder.first!)
                let _ = treesWithSameOrder.removeFirst()
            }
            
            while !treesWithSameOrder.isEmpty {
                let firstTree = treesWithSameOrder.removeFirst()
                let secondTree = treesWithSameOrder.removeFirst()
                first.append(merge(first: firstTree, second: secondTree)!)
            }
        }
    }
    
    func pop() {
        
        if isEmpty {
            return
        }
        
        let index = findMinIndex()
        let treeToRemove = trees[index]
        trees.remove(at: index)
        mergeHeaps(first: trees, second: treeToRemove.childrens)
        
        while !treeToRemove.singletons.isEmpty {
            insertSingleton(singleton: treeToRemove.singletons.first!)
            let _ = treeToRemove.singletons.removeFirst()
        }
        
        elementsCount -= 1
    }
    
    func merge(other: SkewBinomialHeap<Element>) {
        mergeHeaps(first: trees, second: other.trees)
        elementsCount += other.elementsCount
        other.elementsCount = 0
    }
    
}











class BPQNode<Element: Comparable> {
    var value: Element
    var queue: SkewBinomialHeap<BrodalPriorityQueue<Element>>
    
    init(value: Element) {
        self.value = value
        queue = SkewBinomialHeap<BrodalPriorityQueue<Element>>()
    }
    
    init(value: Element, queue: SkewBinomialHeap<BrodalPriorityQueue<Element>>) {
        self.value = value
        self.queue = queue
    }
}

class BrodalPriorityQueue<Element: Comparable> : Comparable {
    
    private var root: BPQNode<Element>?
    
    var isEmpty: Bool {
        return root == nil
    }
    
    //MARK: - Initialization
    
    init() {
        
    }
    
    init(value: Element) {
        root = BPQNode(value: value)
    }
    
    private init(value: Element,
                 queue: SkewBinomialHeap<BrodalPriorityQueue<Element>>) {
        root = BPQNode(value: value, queue: queue)
    }
    
    var first: Element? {
        if isEmpty {
            return nil
        }
        
        return root!.value
    }
    
    func merge(other: BrodalPriorityQueue) {
        if isEmpty {
            root = other.root
            return
        }
        if other.isEmpty {
            return
        }
        
        if root!.value < other.root!.value {
            root!.queue.push(element: other)
            return
        }
        
        let selfCopy = BrodalPriorityQueue<Element>(value: root!.value, queue: root!.queue)
        root!.queue = other.root!.queue
        root!.queue.push(element: selfCopy)
        root!.value = other.root!.value
    }
    
    func insert(element: Element) {
        merge(other: BrodalPriorityQueue(value: element))
    }
    
    func extractMin() -> Element? {
        if isEmpty {
            return nil
        }
        
        let minElement = root!.value
        if root!.queue.isEmpty {
            root = nil
            return minElement
        }
        let minBpq = root!.queue.first!
        root!.queue.pop()
        root!.queue.merge(other: minBpq.root!.queue)
        root!.value = minBpq.root!.value
        return minElement
    }
    
    //MARK: - Comparable
    
    static func <(lhs: BrodalPriorityQueue, rhs: BrodalPriorityQueue) -> Bool {
        if lhs.root == nil {
            return rhs.root != nil
        }
        if rhs.root == nil {
            return false
        }
        return lhs.root!.value < rhs.root!.value
    }
    
    static func <=(lhs: BrodalPriorityQueue, rhs: BrodalPriorityQueue) -> Bool {
        if lhs.root == nil {
            return true
        }
        if rhs.root == nil {
            return false
        }
        return lhs.root!.value <= rhs.root!.value
    }
    
    static func >=(lhs: BrodalPriorityQueue, rhs: BrodalPriorityQueue) -> Bool {
        if lhs.root == nil {
            return rhs.root == nil
        }
        if rhs.root == nil {
            return true
        }
        return lhs.root!.value >= rhs.root!.value
    }
    
    static func >(lhs: BrodalPriorityQueue, rhs: BrodalPriorityQueue) -> Bool {
        if lhs.root == nil {
            return false
        }
        if rhs.root == nil {
            return true
        }
        return lhs.root!.value > rhs.root!.value
    }
    
    //MARK: - Equatable
    
    static func ==(lhs: BrodalPriorityQueue, rhs: BrodalPriorityQueue) -> Bool {
        return lhs.root?.value == rhs.root?.value
    }
}


extension UInt64 {
    var beautifulString: String {
        if self == 0 {
            return "0"
        }
        var result = ""
        var value = self
        var count = -1
        while value != 0 {
            if count % 3 == 2 {
                result = " " + result
            }
            result = "\(value % 10)" + result
            value /= 10
            count += 1
        }
        return result
    }
}











func insert0(queue: BrodalPriorityQueue<Int>) {
    queue.insert(element: 3);
    queue.insert(element: 2);
    queue.insert(element: 1);
    queue.insert(element: 4);
    queue.insert(element: 5);
    queue.insert(element: 0);
    queue.insert(element: -1);
    queue.insert(element: -100);
    queue.insert(element: -20);
    queue.insert(element: 40);
    queue.insert(element: 50);
    queue.insert(element: 45);
}

func insert1(queue: BrodalPriorityQueue<Int>, size: Int) {
    for _ in 0..<size {
        queue.insert(element: 0)
    }
}

func insert2(queue: BrodalPriorityQueue<Int>, size: Int) {
    for i in 0..<size {
        queue.insert(element: i)
    }
}

func insert3(queue: BrodalPriorityQueue<Int>, size: Int) {
    for i in 0..<size {
        queue.insert(element: -i)
    }
}

func insert4(queue: BrodalPriorityQueue<UInt32>, size: Int) {
    for _ in 0..<size {
        let a = arc4random()
        queue.insert(element: a)
    }
}

func insert4(queue: Deque<UInt32>, size: Int) -> Deque<UInt32> {
    var queue = queue
    for _ in 0..<size {
        let a = arc4random()
        if a % 2 == 0 {
            queue.append(0)
        } else {
            queue.prepend(1)
        }
    }
    return queue
}

func extractMins<Element: Comparable>(queue: BrodalPriorityQueue<Element>) {
    var counter = 0
    var last: Element!
    while !queue.isEmpty {
        let element = queue.extractMin()!
        print(element)
        if last == nil {
            last = element
        }
        if last > element {
            print("error at the \(counter)")
            return
        }
        counter += 1
    }
    print("at all \(counter)")
}



func getTime(closure: (Int) -> (), size: Int) {
    let start = DispatchTime.now()
    closure(size)
    let end = DispatchTime.now()
    let interval = end.uptimeNanoseconds - start.uptimeNanoseconds
    print("elapsed within \(interval.beautifulString) nanosecs")
}

func test1(size: Int) {
    let queue = BrodalPriorityQueue<Int>()
    
    var start = DispatchTime.now()
    insert1(queue: queue, size: size)
    var end = DispatchTime.now()
    var interval = end.uptimeNanoseconds - start.uptimeNanoseconds
    print("elapsed within \(interval.beautifulString) nanosecs")
    
    
    start = DispatchTime.now()
    extractMins(queue: queue)
    end = DispatchTime.now()
    interval = end.uptimeNanoseconds - start.uptimeNanoseconds
    print("elapsed within \(interval.beautifulString) nanosecs")
    
    print("done #1")
}
func test2(size: Int) {
    let queue = BrodalPriorityQueue<Int>()
    
    var start = DispatchTime.now()
    insert2(queue: queue, size: size)
    var end = DispatchTime.now()
    var interval = end.uptimeNanoseconds - start.uptimeNanoseconds
    print("elapsed within \(interval.beautifulString) nanosecs")
    
    
    start = DispatchTime.now()
    extractMins(queue: queue)
    end = DispatchTime.now()
    interval = end.uptimeNanoseconds - start.uptimeNanoseconds
    print("elapsed within \(interval.beautifulString) nanosecs")
    
    print("done #2")
}
func test3(size: Int) {
    let queue = BrodalPriorityQueue<Int>()
    
    var start = DispatchTime.now()
    insert3(queue: queue, size: size)
    var end = DispatchTime.now()
    var interval = end.uptimeNanoseconds - start.uptimeNanoseconds
    print("elapsed within \(interval.beautifulString) nanosecs")
    
    
    start = DispatchTime.now()
    extractMins(queue: queue)
    end = DispatchTime.now()
    interval = end.uptimeNanoseconds - start.uptimeNanoseconds
    print("elapsed within \(interval.beautifulString) nanosecs")
    
    print("done #3")
}

func test4(size: Int) {
    let queue = BrodalPriorityQueue<UInt32>()
    
    var start = DispatchTime.now()
    insert4(queue: queue, size: size)
    var end = DispatchTime.now()
    var interval = end.uptimeNanoseconds - start.uptimeNanoseconds
    print("elapsed within \(interval.beautifulString) nanosecs")
    
    
    start = DispatchTime.now()
    extractMins(queue: queue)
    end = DispatchTime.now()
    interval = end.uptimeNanoseconds - start.uptimeNanoseconds
    print("elapsed within \(interval.beautifulString) nanosecs")
    
    print("done #4")
}


func run(input: String) {
    let queue = BrodalPriorityQueue<Int>()
    let data = input.components(separatedBy: " ")
    var index = 0
    while index < data.count {
        if data[index] == "q" {
            print(queue.extractMin())
        } else {
            queue.insert(element: Int(data[index])!)
        }
        index += 1
    }
}

run(input: "1 2 3 4 5 q 4 3 5 q 2 3 4 q q q q q q q q q q")














