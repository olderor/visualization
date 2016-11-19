//: Playground - noun: a place where people can play

enum StructError: Error {
    case outOfElements
}

class HeapNode<Element> {
    var value: Element
    var degree: Int
    var parent: HeapNode<Element>?
    var child: HeapNode<Element>?
    var sibling: HeapNode<Element>?
    
    init(value: Element, degree: Int, parent: HeapNode<Element>?,
         child: HeapNode<Element>?, sibling: HeapNode<Element>?) {
        self.value = value
        self.degree = degree
        self.parent = parent
        self.child = child
        self.sibling = sibling
    }
}

class BinomialHeap<Element: Comparable> {
    
    private var root: HeapNode<Element>?
    
    var empty: Bool {
        return root == nil
    }
    
    var minimum: Element? {
        if empty {
            return nil
        }
        var min = root!.value
        var currentNode = root!.sibling
        while currentNode != nil {
            if currentNode!.value < min {
                min = currentNode!.value
            }
            currentNode = currentNode!.sibling
        }
        return min
    }
    
    func insert(element: Element) {
        root = BinomialHeap.insert(node: root, element: element)
    }
    
    func merge(otherHeap: BinomialHeap) {
        root = BinomialHeap.union(firstNode: root, secondNode: otherHeap.root)
    }
    
    func extractMin() -> Element? {
        if empty {
            return nil
        }
        let result = BinomialHeap.extractMin(root: root!)
        root = result.newRoot
        return result.minElement
    }
    
    private static func merge(firstNode: HeapNode<Element>!, secondNode: HeapNode<Element>!) -> HeapNode<Element>? {
        
        if firstNode == nil {
            return secondNode
        }
        
        if secondNode == nil {
            return firstNode
        }
        
        var newRoot: HeapNode<Element>!
        var currentFirst = firstNode
        var currentSecond = secondNode
        
        if currentFirst!.degree <= currentSecond!.degree {
            newRoot = currentFirst
            currentFirst = currentFirst!.sibling
        } else {
            newRoot = currentSecond
            currentSecond = currentSecond!.sibling
        }
        
        var tail = newRoot!
        while currentFirst != nil && currentSecond != nil {
            if currentFirst!.degree <= currentSecond!.degree {
                tail.sibling = currentFirst!
                currentFirst = currentFirst!.sibling
            } else {
                tail.sibling = currentSecond
                currentSecond = currentSecond!.sibling
            }
            tail = tail.sibling!
        }
        
        if currentFirst != nil {
            tail.sibling = currentFirst
        } else {
            tail.sibling = currentSecond
        }
        
        return newRoot
    }
    
    private static func link(parent: HeapNode<Element>, child: HeapNode<Element>) {
        child.parent = parent
        child.sibling = parent.child
        parent.child = child
        parent.degree += 1
    }
    
    private static func union(firstNode: HeapNode<Element>?, secondNode:
        HeapNode<Element>?) -> HeapNode<Element>? {
        var newRoot = merge(firstNode: firstNode, secondNode: secondNode)
        if newRoot == nil {
            return nil
        }
        
        var currentNode = newRoot!
        var previousNode: HeapNode<Element>?
        var nextNode = currentNode.sibling
        
        while nextNode != nil {
            if currentNode.degree != nextNode!.degree ||
                nextNode!.sibling != nil &&
                nextNode!.sibling!.degree == currentNode.degree {
                previousNode = currentNode
                currentNode = nextNode!
            } else if currentNode.value <= nextNode!.value {
                currentNode.sibling = nextNode!.sibling
                link(parent: currentNode, child: nextNode!)
            } else {
                
                if previousNode != nil {
                    previousNode!.sibling = nextNode
                } else {
                    newRoot = nextNode
                }
                link(parent: nextNode!, child: currentNode)
                currentNode = nextNode!
            }
            nextNode = currentNode.sibling
        }
        return newRoot
    }
    
    private static func insert(node: HeapNode<Element>?, element: Element) -> HeapNode<Element>? {
        let elementNode = HeapNode(value: element, degree: 0, parent: nil, child: nil, sibling: nil)
        return union(firstNode: node, secondNode: elementNode)
    }
    
    private static func extractMin(root: HeapNode<Element>) ->
        (minElement: Element, newRoot: HeapNode<Element>?) {
            var minValue = root.value
            var minNode = root
            var minPreviousNode: HeapNode<Element>!
            var current = root.sibling
            var previous = root
            
            while current != nil {
                if current!.value < minValue {
                    minValue = current!.value
                    minNode = current!
                    minPreviousNode = previous
                }
                previous = current!
                current = current!.sibling
            }
            
            var newRoot: HeapNode<Element>? = root
            if minPreviousNode == nil {
                newRoot = minNode.sibling
            } else {
                minPreviousNode.sibling = minNode.sibling
            }
            
            
            var newRoot2: HeapNode<Element>?
            current = minNode.child
            while current != nil {
                let tempNode = current!.sibling
                current!.sibling = newRoot2
                current!.parent = nil
                newRoot2 = current
                current = tempNode
            }
            
            return (minElement: minValue, newRoot: union(firstNode: newRoot2, secondNode: newRoot))
    }
}











class BPQNode<Element: Comparable> {
    var value: Element
    var queue: BinomialHeap<BrodalPriorityQueue<Element>>
    
    init(value: Element) {
        self.value = value
        queue = BinomialHeap<BrodalPriorityQueue<Element>>()
    }
    
    init(value: Element, queue: BinomialHeap<BrodalPriorityQueue<Element>>) {
        self.value = value
        self.queue = queue
    }
}

class BrodalPriorityQueue<Element: Comparable> : Comparable {
    
    private var root: BPQNode<Element>?
    
    var empty: Bool {
        return root == nil
    }
    
    var minimum: Element? {
        if empty {
            return nil
        }
        return root!.value
    }
    
    //MARK: - Initialization
    
    init() {
    
    }
    
    init(value: Element) {
        root = BPQNode(value: value)
    }
    
    init(value: Element, queue: BinomialHeap<BrodalPriorityQueue<Element>>) {
        root = BPQNode(value: value, queue: queue)
    }
    
    func merge(other: BrodalPriorityQueue) {
        if empty {
            root = other.root
            return
        }
        if other.empty {
            return
        }
        
        if root!.value < other.root!.value {
            root!.queue.insert(element: other)
            return
        }
        
        let selfCopy = BrodalPriorityQueue<Element>(value: root!.value, queue: root!.queue)
        root!.queue = other.root!.queue
        root!.queue.insert(element: selfCopy)
        root!.value = other.root!.value
    }
    
    func insert(element: Element) {
        merge(other: BrodalPriorityQueue(value: element))
    }
    
    func extractMin() -> Element? {
        if empty {
            return nil
        }
        
        let minElement = root!.value
        if root!.queue.empty {
            root = nil
            return minElement
        }
        
        if let minRoot = root!.queue.extractMin()?.root {
            root!.queue.merge(otherHeap: minRoot.queue)
            root!.value = minRoot.value
        }
        
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














func insert(queue: BrodalPriorityQueue<Int>) {
    queue.insert(element: 3);
    queue.insert(element: 2);
    queue.insert(element: 1);
    queue.insert(element: 4);
    queue.insert(element: 5);
    queue.insert(element: 0);
    queue.insert(element: 3);
    queue.insert(element: 2);
    queue.insert(element: 1);
    queue.insert(element: 4);
    queue.insert(element: 5);
    queue.insert(element: 0);
    queue.insert(element: 3);
    queue.insert(element: 2);
    queue.insert(element: 1);
    queue.insert(element: 4);
    queue.insert(element: 5);
    queue.insert(element: 0);
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

func test(queue: BrodalPriorityQueue<Int>) {
    print("printing:")
    while !queue.empty {
        print(queue.extractMin()!)
    }
}


var queue = BrodalPriorityQueue<Int>()
insert(queue: queue)


var queue2 = BrodalPriorityQueue<Int>()
insert(queue: queue2)
queue.merge(other: queue2)
insert(queue: queue)
test(queue: queue)
print("done")



