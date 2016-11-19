//: Playground - noun: a place where people can play

enum StructError: Error {
    case outOfElements
}

class Node<Element> {
    var value: Element
    var degree: Int
    var parent: Node<Element>?
    var child: Node<Element>?
    var sibling: Node<Element>?
    
    init(value: Element, degree: Int, parent: Node<Element>?,
         child: Node<Element>?, sibling: Node<Element>?) {
        self.value = value
        self.degree = degree
        self.parent = parent
        self.child = child
        self.sibling = sibling
    }
}

class BinomialHeap<Element: Comparable> {
    
    private var root: Node<Element>?
    
    init() {
        
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
    
    var empty: Bool {
        return root == nil
    }
    
    func extractMin() -> Element? {
        if empty {
            return nil
        }
        let result = BinomialHeap.extractMin(root: root!)
        root = result.newRoot
        return result.minElement
    }
    
    private static func merge(firstNode: Node<Element>!, secondNode: Node<Element>!) -> Node<Element>? {
        
        if firstNode == nil {
            return secondNode
        }
        
        if secondNode == nil {
            return firstNode
        }
        
        var newRoot: Node<Element>!
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
    
    private static func link(parent: Node<Element>, child: Node<Element>) {
        child.parent = parent
        child.sibling = parent.child
        parent.child = child
        parent.degree += 1
    }
    
    private static func union(firstNode: Node<Element>?, secondNode:
        Node<Element>?) -> Node<Element>? {
        var newRoot = merge(firstNode: firstNode, secondNode: secondNode)
        if newRoot == nil {
            return nil
        }
        
        var currentNode = newRoot!
        var previousNode: Node<Element>?
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
    
    private static func insert(node: Node<Element>?, element: Element) -> Node<Element>? {
        let elementNode = Node(value: element, degree: 0, parent: nil, child: nil, sibling: nil)
        return union(firstNode: node, secondNode: elementNode)
    }
    
    private static func extractMin(root: Node<Element>) ->
        (minElement: Element, newRoot: Node<Element>?) {
            var minValue = root.value
            var minNode = root
            var minPreviousNode: Node<Element>!
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
            
            var newRoot: Node<Element>? = root
            if minPreviousNode == nil {
                newRoot = minNode.sibling
            } else {
                minPreviousNode.sibling = minNode.sibling
            }
            
            
            var newRoot2: Node<Element>?
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




func insert(heap: BinomialHeap<Int>) {
    heap.insert(element: 3);
    heap.insert(element: 2);
    heap.insert(element: 1);
    heap.insert(element: 4);
    heap.insert(element: 5);
    heap.insert(element: 0);
    heap.insert(element: 3);
    heap.insert(element: 2);
    heap.insert(element: 1);
    heap.insert(element: 4);
    heap.insert(element: 5);
    heap.insert(element: 0);
    heap.insert(element: 3);
    heap.insert(element: 2);
    heap.insert(element: 1);
    heap.insert(element: 4);
    heap.insert(element: 5);
    heap.insert(element: 0);
    heap.insert(element: 3);
    heap.insert(element: 2);
    heap.insert(element: 1);
    heap.insert(element: 4);
    heap.insert(element: 5);
    heap.insert(element: 0);
    heap.insert(element: -1);
    heap.insert(element: -100);
    heap.insert(element: -20);
    heap.insert(element: 40);
    heap.insert(element: 50);
    heap.insert(element: 45);
}

func test(heap: BinomialHeap<Int>) {
    print("printing:")
    while !heap.empty {
        print(heap.extractMin()!)
    }
}



var heap = BinomialHeap<Int>()
insert(heap: heap)





