#include <iostream> 
#include <fstream> 
#include <exception>
#include <vector>
#include <queue>
#include <ctime>
#include <iomanip>
#include <functional>
#include <memory>
#include <deque>

#ifdef _DEBUG
#include <crtdbg.h>
#define _CRTDBG_MAP_ALLOC
#endif


class empty_exception : public std::exception {
    virtual const char* what() const throw() {
        return "Trying to extract number from empty structure.";
    }
} empty_exception;







// Skew Binomial Heap
// Used in implementation of priority queues
// Insert worst-case time O(1)
template<class T>
class skew_binomial_heap {
public:

    skew_binomial_heap() {}

    skew_binomial_heap(const skew_binomial_heap& rhs) {
        for (int i = 0; i < rhs.trees.size(); ++i) {
            trees.push_back(clone_tree(rhs.trees[i]));
        }
        elements_count = rhs.elements_count;
    }


    skew_binomial_heap<T>& operator= (const skew_binomial_heap& rhs) {
        skew_binomial_heap copy = rhs;
        swap(copy);
        return *this;
    }

    void swap(skew_binomial_heap& rhs) {
        std::swap(elements_count, rhs.elements_count);
        trees.swap(rhs.trees);
    }

    int size() const {
        return elements_count;
    }

    bool empty() const {
        return elements_count == 0;
    }

    void push(const T &value) {
        insert_singleton(std::make_shared<tree>(tree(value, 0)));
        ++elements_count;
    }

    T top() {
        return trees[find_min_index()]->value;
    }

    void merge(skew_binomial_heap<T> &other) {
        merge_heaps(trees, other.trees);
        elements_count += other.elements_count;
        other.elements_count = 0;
    }

    void pop() {
        int index = find_min_index();
        std::shared_ptr<tree> tree_to_remove = trees[index];
        trees.erase(trees.begin() + index);

        merge_heaps(trees, tree_to_remove->childrens);

        while (!tree_to_remove->singletons.empty()) {
            insert_singleton(tree_to_remove->singletons.front());
            tree_to_remove->singletons.pop_front();
        }

        --elements_count;
    }
private:
    struct tree {
        int order;
        std::deque<std::shared_ptr<tree>> childrens;
        std::deque<std::shared_ptr<tree>> singletons;
        T value;

        tree(const T &value, int order) : value(value), order(order) {

        }
    };

    std::deque<std::shared_ptr<tree>> trees;
    int elements_count = 0;

    std::shared_ptr<tree> clone_tree(const std::shared_ptr<tree> tree_to_clone) {
        if (!tree_to_clone) {
            return nullptr;
        }

        std::shared_ptr<tree> result = std::make_shared<tree>(tree(tree_to_clone->value, tree_to_clone->order));

        for (int i = 0; i < tree_to_clone->childrens.size(); ++i) {
            result->childrens.push_back(clone_tree(tree_to_clone->childrens[i]));
        }
        for (int i = 0; i < tree_to_clone->singletons.size(); ++i) {
            result->singletons.push_back(clone_tree(tree_to_clone->singletons[i]));
        }

        return result;
    }

    void insert_singleton(std::shared_ptr<tree> singleton) {
        if (!(trees.size() >= 2 && trees[0]->order == trees[1]->order)) {
            trees.push_front(singleton);
            return;
        }

        std::shared_ptr<tree> first = trees.front();
        trees.pop_front();
        std::shared_ptr<tree> second = trees.front();
        trees.pop_front();

        std::shared_ptr<tree> new_tree = merge(first, second);
        if (singleton->value < new_tree->value) {
            std::swap(singleton->value, new_tree->value);
        }

        new_tree->singletons.push_back(singleton);
        trees.push_front(new_tree);
    }

    std::shared_ptr<tree> merge(std::shared_ptr<tree> first, std::shared_ptr<tree> second) {

        if (second->value < first->value) {
            std::swap(first, second);
        }

        first->childrens.push_back(second);
        ++first->order;
        return first;
    }

    void merge_heaps(std::deque<std::shared_ptr<tree>> &first, std::deque<std::shared_ptr<tree>> &second) {
        std::deque<std::shared_ptr<tree>> result;
        while (!first.empty() && !second.empty()) {
            if (first.front()->order < second.front()->order) {
                result.push_back(first.front());
                first.pop_front();
            } else {
                result.push_back(second.front());
                second.pop_front();
            }
        }
        while (!first.empty()) {
            result.push_back(first.front());
            first.pop_front();
        }
        while (!second.empty()) {
            result.push_back(second.front());
            second.pop_front();
        }


        while (!result.empty()) {
            std::deque<std::shared_ptr<tree>> trees_with_same_order;
            trees_with_same_order.push_back(result.front());
            result.pop_front();

            while (!result.empty() &&
                result.front()->order == trees_with_same_order.front()->order) {
                trees_with_same_order.push_back(result.front());
                result.pop_front();
            }

            if (trees_with_same_order.size() % 2 == 1) {
                first.push_back(trees_with_same_order.front());
                trees_with_same_order.pop_front();
            }

            while (!trees_with_same_order.empty()) {
                std::shared_ptr<tree> first_tree = trees_with_same_order.front();
                trees_with_same_order.pop_front();
                std::shared_ptr<tree> second_tree = trees_with_same_order.front();
                trees_with_same_order.pop_front();

                first.push_front(merge(first_tree, second_tree));
            }
        }
    }

    int find_min_index() {
        int index = 0;
        for (int i = 1; i < trees.size(); ++i) {
            if (trees[i]->value < trees[index]->value) {
                index = i;
            }
        }
        return index;
    }
};


template<class T>
using priority_queue = skew_binomial_heap<T>;
















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
        node *current = root->sibling;
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
        node *parent = nullptr;
        node *child = nullptr;
        node *sibling = nullptr;
    };

    node *root = nullptr;

    // Insert value into the node.
    static node *insert(node *h1, T value) {
        node *new_root = std::make_shared<node>(node());
        new_root->value = value;
        return union_heaps(h1, new_root);
    }

    // Merge two nodes and return the root.
    static node *merge(node *h1, node *h2) {
        if (!h1) {
            return h2;
        }
        if (!h2) {
            return h1;
        }
        node *new_root = nullptr;
        node *current_h1 = h1;
        node *current_h2 = h2;

        if (current_h1->degree <= current_h2->degree) {
            new_root = current_h1;
            current_h1 = current_h1->sibling;
        } else {
            new_root = current_h2;
            current_h2 = current_h2->sibling;
        }

        node *tail = new_root;
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
    static node *union_heaps(node *h1, node *h2) {
        node *new_root = merge(h1, h2);
        if (!new_root) {
            return nullptr;
        }

        node *prev = nullptr;
        node *next = new_root->sibling;
        node *current = new_root;
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

    static void link(node *parent, node *child) {
        child->parent = parent;
        child->sibling = parent->child;
        parent->child = child;
        ++parent->degree;
    }

    // Extract the minimum element in the heap.
    // Return the minimum element and new root of the heap.
    static std::pair<T, node *> extract_min(node *root) {
        if (!root) {
            throw empty_exception;
        }
        T min_value = root->value;
        node *min_node = root;
        node *min_prev = nullptr;
        node *current = root->sibling;
        node *prev = root;
        while (current) {
            if (current->value < min_value) {
                min_value = current->value;
                min_node = current;
                min_prev = prev;
            }
            prev = current;
            current = current->sibling;
        }
        node *new_root = root;
        if (!min_prev) {
            // node to remove is root.
            new_root = min_node->sibling;
        } else {
            min_prev->sibling = min_node->sibling;
        }

        node *new_root2 = nullptr;
        current = min_node->child;
        while (current) {
            node *temp = current->sibling;
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
using priority_queue2 = binomial_heap<T>;




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
            root->queue.push(other);
            return;
        }

        const bpq copy = bpq(root->value, root->queue);

        root->queue = other.root->queue;
        root->queue.push(copy);
        root->value = other.root->value;
    }

    // Insert the element into the bpq.
    // Time efficiency O(1).
    void push(const T value) {
        merge(bpq(value));
    }

    // Find the minimum value in the bpq.
    // Time efficiency O(1).
    // Return T - minimum value.
    T top() {
        if (empty()) {
            throw empty_exception;
        }
        return root->value;
    }

    // Find and delete the minimum value in the bpq.
    // Time efficiency O(log n).
    // Return T - minimum value, that was removed.
    T pop() {
        if (empty()) {
            throw empty_exception;
        }
        const T min_value = root->value;
        if (root->queue.empty()) {
            root = nullptr;
            return min_value;
        }

        priority_queue<bpq> new_queue(root->queue);
        const bpq min_bpq = new_queue.top();
        new_queue.pop();
        new_queue.merge(min_bpq.root->queue);
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
















std::pair<int, int> test(bpq<int> &q1) {
    clock_t t1 = 0, t2 = 0;

    while (!q1.empty()) {
        clock_t begin, end;
        begin = clock();
        q1.top();
        end = clock();
        t1 += end - begin;

        begin = clock();
        q1.pop();
        end = clock();
        t2 += end - begin;
    }

    return std::make_pair(t1, t2);
}
void test(std::priority_queue<int, std::vector<int>, std::greater<int> > &q1) {
    while (!q1.empty()) {
        q1.pop();
    }
}

void insert1(bpq<int> &q1) {
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
void insert2(bpq<int> &q1, const int n) {
    for (int i = 0; i < n; ++i) {
        q1.push(0);
    }
}
void insert3(bpq<int> &q1, const int n) {
    for (int i = 0; i < n; ++i) {
        q1.push(i);
    }
}
void insert4(bpq<int> &q1, const int n) {
    for (int i = 0; i < n; ++i) {
        q1.push(-i);
    }
}
void insert5(bpq<int> &q1, std::vector<int> &numbers) {
    for (int i = 0; i < numbers.size(); ++i) {
        q1.push(numbers[i]);
    }
}

void insert6(bpq<int> &q1, const int n) {
    for (int i = 0; i < n; ++i) {
        q1.push(rand());
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


    std::ofstream cout("timing3.txt", std::ios::app);

    bpq<int> bpq;

    clock_t begin, end;

    // 1
    cout << "\ninsert1 " << n << "\n";
    begin = clock();
    insert2(bpq, n);
    end = clock();
    cout << "bpq: " << end - begin << '\n';

    cout << "\npop\n";
    begin = clock();
    test(bpq);
    end = clock();
    cout << "bpq: " << end - begin << '\n';


    std::cout << "test #1 - done\n";

    // 2
    cout << "\ninsert2 " << n << "\n";
    begin = clock();
    insert3(bpq, n);
    end = clock();
    cout << "bpq: " << end - begin << '\n';

    cout << "\npop\n";

    begin = clock();
    test(bpq);
    end = clock();
    cout << "bpq: " << end - begin << '\n';


    std::cout << "test #2 - done\n";


    // 3
    cout << "\ninsert3 " << n << "\n";
    begin = clock();
    insert4(bpq, n);
    end = clock();
    cout << "bpq: " << end - begin << '\n';

    cout << "\npop\n";

    begin = clock();
    test(bpq);
    end = clock();
    cout << "bpq: " << end - begin << '\n';



    std::cout << "test #3 - done\n";

    // 4
    cout << "\ninsert4 " << n << "\n";
    begin = clock();
    insert6(bpq, n);
    end = clock();
    cout << "bpq: " << end - begin << '\n';

    cout << "\npop\n";
    begin = clock();
    test(bpq);
    end = clock();
    cout << "bpq: " << end - begin << '\n';
    std::cout << "test #4 - done\n";

    cout.close();
}


void test_merge(int n) {

    std::ofstream cout("timing3.txt", std::ios::app);
    
    clock_t begin, end;

    bpq<int> q1;
    bpq<int> q2;
    cout << "\ninsert4 " << n << "\n";
    begin = clock();
    insert6(q1, n);
    end = clock();
    cout << "bpq: " << end - begin << '\n';

    cout << "\ninsert4 " << n << "\n";
    begin = clock();
    insert6(q2, n);
    end = clock();
    cout << "bpq: " << end - begin << '\n';

    cout << "\nmerge " << n << "\n";
    begin = clock();
    q1.merge(q2);
    end = clock();
    cout << "bpq: " << end - begin << '\n';


    std::cout << "insert merge done\n";

    cout << "\ntop" << n << "\n";
    std::pair<int, int> res = test(q2);
    cout << "bpq: " << res.first << '\n';
    cout << "\npop" << n << "\n";
    cout << "bpq: " << res.second << '\n';

    std::cout << "first pop done\n";

    cout << "\ntop" << n + n << "\n";
    res = test(q1);
    cout << "bpq: " << res.first << '\n';
    cout << "\npop" << n + n << "\n";
    cout << "bpq: " << res.second << '\n';

    std::cout << "second pop done\n";

}

void console_test(int n) {


    bpq<int> bpq;
    std::cout << "\ninsert2 " << n << "\n";
    insert2(bpq, n);

    std::cout << "\npop\n";
    while (!bpq.empty()) {
        std::cout << bpq.top() << " ";
        bpq.pop();
    }
    std::cout << '\n';
    std::cout << "\ninsert3 " << n << "\n";
    insert3(bpq, n);

    std::cout << "\npop\n";
    while (!bpq.empty()) {
        std::cout << bpq.top() << " ";
        bpq.pop();
    }
    std::cout << '\n';

    std::cout << "\ninsert4 " << n << "\n";
    insert4(bpq, n);

    std::cout << "\npop\n";
    while (!bpq.empty()) {
        std::cout << bpq.top() << " ";
        bpq.pop();
    }
    std::cout << '\n';


    std::cout << "\ninsert6 " << n << "\n";
    insert6(bpq, n);

    std::cout << "\npop\n";
    while (!bpq.empty()) {
        std::cout << bpq.top() << " ";
        bpq.pop();
    }
    std::cout << '\n';
}




int main() {

    /*
    int s = 1000;
    for (int i = 0; i < 10; ++i, s += 1000) {
    std::cout << "testing #" << i + 1 << '\n';
    testAll(s);
    }*/

    _CrtDumpMemoryLeaks();


    
    int s = 1000;
    for (int i = 0; i < 10; ++i, s += 1000) {
        test_merge(s);
        std::cout << "test " << i + 1 << "done\n";
    }

    return 0;
}
