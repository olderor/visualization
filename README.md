# visualization
Visualize data structures (Skew Binomial Heap and Brodal-Okasaki Priority Queue)

<img src="http://i.imgur.com/e5R2P7U.jpg" />

You can test structure using Xcode with playground available [here](forest/MyPlayground.playground)</br>
All you need is to download MyPlayground.playground to your local pc and open it using Xcode.</br>
Or you can try to use [swift online compiler](https://www.google.com/search?q=swift+online+compiler) by copy-pasting into it code [from here](forest/MyPlayground.playground/Contents.swift) (warning, this may not work as expected)
```swift
// create new queue of integer type.
var queue = BrodalPriorityQueue<Int>()

// add number to the queue.
queue.insert(element: 42)

// retrieve the minimum element. 
// prints Optional(42).
// queue still contains 42.
print(queue.first)

// retrieve and delete the minimum element.
// prints Optional(42).
// now queue doesn't contain 42, queue is empty.
print(queue.extractMin())
```

Also you can use custom tests by runing functions:
```swift
// testing functions.
// parameter size: Int - number of elements for testing.
// each function inserts elements by the rules described below.
// after that it extracts min element while queue is not empty and prints that element to console.
// each function also prints time wasted on insertation and extraction.

// test #1
// this test inserts elements with equal value (0) 'size' times. 
test1(size: 100) // test #1 for 100 elements.

// test #2
// this test inserts elements in increasing order 'size' times starting from 0 up to 'size'.
test2(size: 100) // test #2 for 100 elements.

// test #3
// this test inserts elements in decreasing order 'size' times starting from 0 down to -('size').
test3(size: 100) // test #3 for 100 elements.

// test #4
// this test inserts random elements (new element is generated each time, element has type of UInt32) 'size' times.
test4(size: 100) // test #4 for 100 elements.
```
