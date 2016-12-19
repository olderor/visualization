# visualization
visualize data structures (Skew Binomial Heap and Brodal's and Okasaki's Priority Queue)

you can test structure using Xcode with playground available [here](forest/MyPlayground.playground)

```swift
var queue = BrodalPriorityQueue<Int>() // create new queue of integer type.

queue.insert(element: 42) // add number to the queue.

print(queue.first) // retrieve the minimum element. 
                   // prints Optional(42).
                   // queue still contains 42.

print(queue.extractMin()) // retrieve and delete the minimum element. 
                          // prints Optional(42).
                          // now queue doesn't contain 42, queue is empty.
```
