#include <iostream> 
#include <fstream> 
#include <exception>
#include <vector>
#include <queue>
#include <ctime>
#include <iomanip>
#include <functional>
#include <memory>
#ifdef _DEBUG
#include <crtdbg.h>
#define _CRTDBG_MAP_ALLOC
#endif


class empty_exception : public std::exception {
    virtual const char* what() const throw() {
        return "Trying to extract number from empty structure.";
    }
} empty_exception;

// Binomial Heap
// Used in implementation of priority queues
template<class T>
class binomial_heap {
public:
    binomial_heap() {}
    // Find the minimum element in the heap.
    // Time efficiency O(log n).
    // Return T - minimum value.
    T get_minimum() {
        if (empty()) {
            throw empty_exception;
        }

        T min = root->value;
        std::shared_ptr<node> current = root->sibling;
        while (current) {
            if (current->value < min) {
                min = current->value;
            }
            current = current->sibling;
        }
        return min;
    }

    // Insert the value into the heap.
    // Time efficiency O(log n), O(1) - amortized time.
    void insert(T value) {
        root = binomial_heap::insert(root, value);
    }

    // Union two different heaps into one.
    // Time efficiency O(log n).
    void union_heaps(binomial_heap other) {
        root = binomial_heap::union_heaps(root, other.root);
    }

    // Check if the heap is empty.
    // Time efficiency O(1).
    // Return bool - true if the heap is empty, false otherwise.
    bool empty() {
        return !root;
    }

    // Find and delete the minimum element from the heap
    // Time efficiency O(log n).
    // Return T - minimum value, that was removed.
    T extract_min() {
        const std::pair<T, std::shared_ptr<node>> res = binomial_heap::extract_min(root);
        root = res.second;
        return res.first;
    }

private:
    struct node {
        T value;
        int degree = 0;
        std::shared_ptr<node> parent = nullptr;
        std::shared_ptr<node> child = nullptr;
        std::shared_ptr<node> sibling = nullptr;
        ~node() {
            parent = nullptr;
            child = nullptr;
            sibling = nullptr;
        }
    };

    std::shared_ptr<node> root = nullptr;

    // Insert value into the node.
    static std::shared_ptr<node> insert(std::shared_ptr<node> h1, T value) {
        std::shared_ptr<node> new_root = std::make_shared<node>(node());
        new_root->value = value;
        return union_heaps(h1, new_root);
    }

    // Merge two nodes and return the root.
    static std::shared_ptr<node> merge(std::shared_ptr<node> h1, std::shared_ptr<node> h2) {
        if (!h1) {
            return h2;
        }
        if (!h2) {
            return h1;
        }
        std::shared_ptr<node> new_root = nullptr;
        std::shared_ptr<node> current_h1 = h1;
        std::shared_ptr<node> current_h2 = h2;

        if (current_h1->degree <= current_h2->degree) {
            new_root = current_h1;
            current_h1 = current_h1->sibling;
        } else {
            new_root = current_h2;
            current_h2 = current_h2->sibling;
        }

        std::shared_ptr<node> tail = new_root;
        while (current_h1 && current_h2)
        {
            if (current_h1->degree <= current_h2->degree) {
                tail->sibling = current_h1;
                current_h1 = current_h1->sibling;
            } else {
                tail->sibling = current_h2;
                current_h2 = current_h2->sibling;
            }
            tail = tail->sibling;
        }

        if (current_h1) {
            tail->sibling = current_h1;
        } else {
            tail->sibling = current_h2;
        }

        return new_root;
    }

    // Union two different heaps into one and return the root.
    static std::shared_ptr<node> union_heaps(std::shared_ptr<node> h1, std::shared_ptr<node> h2) {
        std::shared_ptr<node> new_root = merge(h1, h2);
        if (!new_root) {
            return nullptr;
        }

        std::shared_ptr<node> prev = nullptr;
        std::shared_ptr<node> next = new_root->sibling;
        std::shared_ptr<node> current = new_root;
        while (next)
        {
            if ((current->degree != next->degree) || (next->sibling
                && next->sibling->degree == current->degree)) {
                prev = current;
                current = next;
            } else if (current->value <= next->value) {
                current->sibling = next->sibling;
                link(current, next);
            } else {
                if (prev) {
                    prev->sibling = next;
                } else {
                    new_root = next;
                }
                link(next, current);
                current = next;
            }
            next = current->sibling;
        }
        return new_root;
    }

    static void link(std::shared_ptr<node> parent, std::shared_ptr<node> child) {
        child->parent = parent;
        child->sibling = parent->child;
        parent->child = child;
        ++parent->degree;
    }

    // Extract the minimum element in the heap.
    // Return the minimum element and new root of the heap.
    static std::pair<T, std::shared_ptr<node> > extract_min(std::shared_ptr<node> root) {
        if (!root) {
            throw empty_exception;
        }
        T min_value = root->value;
        std::shared_ptr<node> min_node = root;
        std::shared_ptr<node> min_prev = nullptr;
        std::shared_ptr<node> current = root->sibling;
        std::shared_ptr<node> prev = root;
        while (current) {
            if (current->value < min_value) {
                min_value = current->value;
                min_node = current;
                min_prev = prev;
            }
            prev = current;
            current = current->sibling;
        }
        std::shared_ptr<node> new_root = root;
        if (!min_prev) {
            // node to remove is root.
            new_root = min_node->sibling;
        } else {
            min_prev->sibling = min_node->sibling;
        }

        std::shared_ptr<node> new_root2 = nullptr;
        current = min_node->child;
        while (current) {
            std::shared_ptr<node> temp = current->sibling;
            current->sibling = new_root2;
            current->parent = nullptr;
            new_root2 = current;
            current = temp;
        }
        new_root = union_heaps(new_root2, new_root);
        return std::make_pair(min_value, new_root);
    }
};

template<class T>
using priority_queue = binomial_heap<T>;


// Brodal's and Okasaki's Priority Queue (bpq)
// Heap/priority queue structure with very low worst case time bounds.
// Based on data-structural bootstrapping.
template<class T>
class bpq {
public:
    bpq() {}
    explicit bpq(const T value) {
        root = std::make_shared<node>(node());
        root->value = value;
    }

    bpq(const T value, priority_queue<bpq> &queue) {
        root = std::make_shared<node>(node());
        root->value = value;
        root->queue = queue;
    }

    // Check if the heap is empty.
    // Time efficiency O(1).
    // Return bool - true if the heap is empty, false otherwise.
    bool empty() {
        return !root;
    }

    // Insert all elements from the other bpq.
    // Time efficiency O(1).
    void merge(bpq &other) {
        if (empty()) {
            root = other.root;
            return;
        }
        if (other.empty()) {
            return;
        }
        if (root->value < other.root->value) {
            root->queue.insert(other);
            return;
        }

        const bpq copy = bpq(root->value, root->queue);

        root->queue = other.root->queue;
        root->queue.insert(copy);
        root->value = other.root->value;
    }

    // Insert the element into the bpq.
    // Time efficiency O(1).
    void insert(const T value) {
        merge(bpq(value));
    }

    // Find the minimum value in the bpq.
    // Time efficiency O(1).
    // Return T - minimum value.
    T get_min() {
        if (empty()) {
            throw empty_exception;
        }
        return root->value;
    }

    // Find and delete the minimum value in the bpq.
    // Time efficiency O(log n).
    // Return T - minimum value, that was removed.
    T extract_min() {
        if (empty()) {
            throw empty_exception;
        }
        const T min_value = root->value;
        if (root->queue.empty()) {
            root = nullptr;
            return min_value;
        }
        priority_queue<bpq> new_queue(root->queue);
        const bpq min_bpq = new_queue.extract_min();
        new_queue.union_heaps(min_bpq.root->queue);
        root->value = min_bpq.root->value;
        root->queue = new_queue;
        return min_value;
    }

    friend bool operator <(const bpq &q1, const bpq &q2) {
        return q1.root->value < q2.root->value;
    }
    friend bool operator <=(const bpq &q1, const bpq &q2) {
        return q1.root->value <= q2.root->value;
    }
    friend bool operator >(const bpq &q1, const bpq &q2) {
        return q1.root->value > q2.root->value;
    }
    friend bool operator >=(const bpq &q1, const bpq &q2) {
        return q1.root->value > q2.root->value;
    }

    // Merge two bpq.
    // Time efficiency O(1).
    // Return bpq - new bpq, the result of the merging.
    static bpq merge(bpq &bpq1, bpq &bpq2) {
        if (bpq1.empty()) {
            return bpq(bpq2);
        }
        if (bpq2.empty()) {
            return bpq(bpq1);
        }
        if (bpq1.root->value < bpq2.root->value) {
            const priority_queue<bpq> new_queue = bpq1.root->queue;
            new_queue.insert(bpq2);
            return bpq(bpq1.root->value, new_queue);
        }
        const priority_queue<bpq> new_queue = bpq2.root->queue;
        new_queue.insert(bpq1);
        return bpq(bpq2.root->value, new_queue);
    }

    // Insert the element into the bpq.
    // Time efficiency O(1).
    // Return bpq - new bpq, the result of the inserting.
    static bpq insert(bpq &bpq1, const T value) {
        return merge(bpq1, bpq(value));
    }

    // Find the minimum value in the bpq.
    // Time efficiency O(1).
    // Return T - minimum value.
    static T get_min(bpq &bpq1) {
        if (bpq1.empty()) {
            throw empty_exception;
        }
        return bpq1.root->value;
    }

    // Find and delete the minimum value in the bpq.
    // Time efficiency O(log n).
    // Return pair<T, bpq>:
    // T - minimum value, that was removed.
    // bpq - new bpq, the result of the removing.
    static std::pair<T, bpq> extract_min(bpq &bpq1) {
        if (bpq1.empty()) {
            throw empty_exception;
        }
        if (bpq1.root->queue.empty()) {
            return std::make_pair(bpq1.root->value, bpq());
        }
        const priority_queue<bpq> new_queue(bpq1.root->queue);
        const bpq min_bpq = new_queue.extract_min();
        new_queue.union_heaps(min_bpq.root->queue);
        return std::make_pair(bpq1.root->value, bpq(min_bpq.root->value, new_queue));
    }

private:
    struct node {
        T value;
        priority_queue<bpq> queue;
    };

    std::shared_ptr<node> root = nullptr;
};

template<class T>
using brodal_priority_queue = bpq<T>;
















void test(bpq<int> &q1) {
    while (!q1.empty()) {
        q1.extract_min();
    }
}
void test(std::priority_queue<int, std::vector<int>, std::greater<int> > &q1) {
    while (!q1.empty()) {
        q1.pop();
    }
}

void insert1(bpq<int> &q1) {
    q1.insert(3);
    q1.insert(2);
    q1.insert(1);
    q1.insert(4);
    q1.insert(5);
    q1.insert(0);
    q1.insert(3);
    q1.insert(2);
    q1.insert(1);
    q1.insert(4);
    q1.insert(5);
    q1.insert(0);
    q1.insert(3);
    q1.insert(2);
    q1.insert(1);
    q1.insert(4);
    q1.insert(5);
    q1.insert(0);
    q1.insert(3);
    q1.insert(2);
    q1.insert(1);
    q1.insert(4);
    q1.insert(5);
    q1.insert(0);
    q1.insert(-1);
    q1.insert(-10000000);
    q1.insert(-20);
    q1.insert(40);
    q1.insert(50);
    q1.insert(45);
}
void insert2(bpq<int> &q1, const int n) {
    for (int i = 0; i < n; ++i) {
        q1.insert(0);
    }
}
void insert3(bpq<int> &q1, const int n) {
    for (int i = 0; i < n; ++i) {
        q1.insert(i);
    }
}
void insert4(bpq<int> &q1, const int n) {
    for (int i = 0; i < n; ++i) {
        q1.insert(-i);
    }
}
void insert5(bpq<int> &q1, std::vector<int> &numbers) {
    for (int i = 0; i < numbers.size(); ++i) {
        q1.insert(numbers[i]);
    }
}

void insert6(bpq<int> &q1, const int n) {
    for (int i = 0; i < n; ++i) {
        q1.insert(rand());
    }
}



void insert1(std::priority_queue<int, std::vector<int>, std::greater<int> > &q1) {
    q1.push(3);
    q1.push(2);
    q1.push(1);
    q1.push(4);
    q1.push(5);
    q1.push(0);
    q1.push(3);
    q1.push(2);
    q1.push(1);
    q1.push(4);
    q1.push(5);
    q1.push(0);
    q1.push(3);
    q1.push(2);
    q1.push(1);
    q1.push(4);
    q1.push(5);
    q1.push(0);
    q1.push(3);
    q1.push(2);
    q1.push(1);
    q1.push(4);
    q1.push(5);
    q1.push(0);
    q1.push(-1);
    q1.push(-10000000);
    q1.push(-20);
    q1.push(40);
    q1.push(50);
    q1.push(45);
}
void insert2(std::priority_queue<int, std::vector<int>, std::greater<int> > &q1, const int n) {
    for (int i = 0; i < n; ++i) {
        q1.push(0);
    }
}
void insert3(std::priority_queue<int, std::vector<int>, std::greater<int> > &q1, const int n) {
    for (int i = 0; i < n; ++i) {
        q1.push(i);
    }
}
void insert4(std::priority_queue<int, std::vector<int>, std::greater<int> > &q1, const int n) {
    for (int i = 0; i < n; ++i) {
        q1.push(-i);
    }
}
void insert5(std::priority_queue<int, std::vector<int>, std::greater<int> > &q1, std::vector<int> &numbers) {
    for (int i = 0; i < numbers.size(); ++i) {
        q1.push(numbers[i]);
    }
}

std::vector<int> generate(const int n) {
    std::vector<int> numbers;
    for (int i = 0; i < n; ++i) {
        numbers.push_back(rand());
    }
    return numbers;
}







void testAll(const int n) {


    std::ofstream cout("timing.txt", std::ios::app);

    bpq<int> bpq;

    clock_t begin, end;



    // 2
    cout << "\ninsert2 " << n << "\n";
    /*begin = clock();
    insert2(queue, 1000000);
    end = clock();
    cout << "pq: " << end - begin << '\n';*/
    begin = clock();
    insert2(bpq, n);
    end = clock();
    cout << "bpq: " << end - begin << '\n';

    cout << "\nextract_min\n";/*
                              begin = clock();
                              test(queue);
                              end = clock();
                              cout << "pq: " << end - begin << '\n';*/
    begin = clock();
    test(bpq);
    end = clock();
    cout << "bpq: " << end - begin << '\n';


    std::cout << "test #2 - done\n";

    // 3
    cout << "\ninsert3 " << n << "\n";/*
                                  begin = clock();
                                  insert3(queue, 1000000);
                                  end = clock();
                                  cout << "pq: " << end - begin << '\n';*/
    begin = clock();
    insert3(bpq, n);
    end = clock();
    cout << "bpq: " << end - begin << '\n';

    cout << "\nextract_min\n";/*
                              begin = clock();
                              test(queue);
                              end = clock();
                              cout << "pq: " << end - begin << '\n';*/
    begin = clock();
    test(bpq);
    end = clock();
    cout << "bpq: " << end - begin << '\n';


    std::cout << "test #3 - done\n";


    // 4
    cout << "\ninsert4 " << n << "\n";/*
                                  begin = clock();
                                  insert4(queue, 1000000);
                                  end = clock();
                                  cout << "pq: " << end - begin << '\n';*/
    begin = clock();
    insert4(bpq, n);
    end = clock();
    cout << "bpq: " << end - begin << '\n';

    cout << "\nextract_min\n";/*
                              begin = clock();
                              test(queue);
                              end = clock();
                              cout << "pq: " << end - begin << '\n';*/
    begin = clock();
    test(bpq);
    end = clock();
    cout << "bpq: " << end - begin << '\n';



    std::cout << "test #4 - done\n";

    // 5
    cout << "\ninsert5 " << n << "\n";
    /*
    begin = clock();
    insert4(queue, 1000000);
    end = clock();
    cout << "pq: " << end - begin << '\n';*/
    begin = clock();
    insert6(bpq, n);
    end = clock();
    cout << "bpq: " << end - begin << '\n';

    cout << "\nextract_min\n";
    /*
    begin = clock();
    test(queue);
    end = clock();
    cout << "pq: " << end - begin << '\n';*/
    begin = clock();
    test(bpq);
    end = clock();
    cout << "bpq: " << end - begin << '\n';



    std::cout << "test #5 - done\n";

    cout.close();
}


void foo() {

    binomial_heap<int> bh;
    bh.insert(1);
}

int main() {

    //std::cout << "testing #1\n";
    //testAll(1000000);
    //std::cout << "testing #2\n";
    //testAll(2000000);
    std::cout << "testing #3\n";
    testAll(100);
    _CrtDumpMemoryLeaks();
    //std::cout << "testing #4\n";
    //testAll(4000000);

    return 0;
}
