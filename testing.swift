//: Playground - noun: a place where people can play
import Foundation

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
            result.removeFirst()
            
            while !result.isEmpty &&
                result.first!.order == treesWithSameOrder.first!.order {
                    treesWithSameOrder.append(result.first!)
                    result.removeFirst()
            }
            
            if treesWithSameOrder.count % 2 == 1 {
                first.append(treesWithSameOrder.first!)
                treesWithSameOrder.removeFirst()
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
            treeToRemove.singletons.removeFirst()
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

func extractMins<Element>(queue: BrodalPriorityQueue<Element>) {
    var counter = 0
    while !queue.isEmpty {
        print(queue.extractMin()!)
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
