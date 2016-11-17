#include <iostream> 
#include <fstream> 
#include <vector>
#include <algorithm>
#include <queue>


// insert O(1)
// merge O(log n)
// extract min O(log n)


// binomial heap
// used in implementation of priority queues
template<class T>
class binomial_heap {
public:
    // find minimum value in the heap.
    // time efficiency O(log n).
    // return T - minimum value.
    T get_minimum() {
        if (empty()) {
            throw;
        }

        T min = root->value;
        node *current = root->sibling;
        while (current) {
            if (min > current->value) {
                min = current->value;
            }
            current = current->sibling;
        }
        return min;
    }

    void insert(T value) {
        root = binomial_heap::insert(root, value);
    }

    void merge(binomial_heap other) {
        root = binomial_heap::union_heaps(root, other.root);
    }

    // check if heap is empty.
    // time efficiency O(1).
    // return bool - true if heap is empty, false otherwise.
    bool empty() {
        return size == 0;
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
    int size = 0;

    static node *insert(node *h1, T value) {
        node *new_root = new node();
        new_root->value = value;
        h1 = union_heaps(h1, new_root);
        return h1;
    }

    static node *merge(node *h1, node *h2) {
        node *new_root = new node();
        node *current_h1 = h1;
        node *current_h2 = h2;
        if (!current_h1) {
            return current_h2;
        }
        if (!current_h2) {
            return current_h1;
        }
        if (current_h1->degree <= current_h2->degree) {
            new_root = current_h1;
        } else {
            new_root = current_h2;
        }
        while (current_h1 && current_h2)
        {
            if (current_h1->degree < current_h2->degree) {
                current_h1 = current_h1->sibling;
            } else if (current_h1->degree == current_h2->degree) {
                node *temp = current_h1->sibling;
                current_h1->sibling = current_h2;
                current_h1 = temp;
            } else
            {
                node *temp = current_h2->sibling;
                current_h2->sibling = current_h1;
                current_h2 = temp;
            }
        }
        return new_root;
    }

    static node *union_heaps(node *h1, node *h2) {
        node *new_root = merge(h1, h2);
        if (!new_root) {
            return new_root;
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
                link(next, current);
            } else {
                if (!prev) {
                    new_root = next;
                } else {
                    prev->sibling = next;
                }
                link(current, next);
                current = next;
            }
            next = current->sibling;
        }
        return new_root;
    }

    static void link(node *child, node *parent) {
        child->parent = parent;
        child->sibling = parent->child;
        parent->child = child;
        parent->degree = parent->degree + 1;
    }
};

template<class T>
using priority_queue = binomial_heap<T>;

struct bpq {
public:
    bpq() {}

    bpq(const bpq& other) {
        if (!other.root) {
            return;
        }

        root = new node();
        root->value = other.root->value;
        root->queue = other.root->queue;
    }

    explicit bpq(const int value) {
        this->root = new node();
        this->root->value = value;
    }

    bpq(const int value, std::priority_queue<bpq> &queue) {
        this->root = new node();
        this->root->value = value;
        this->root->queue = std::priority_queue<bpq>(queue);
    }

    bool empty() {
        return !root;
    }

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

        bpq copy = bpq(root->value, root->queue);

        root->queue = other.root->queue;
        root->queue.push(copy);
        root->value = other.root->value;
    }

    void insert(const int value) {
        merge(bpq(value));
    }

    friend bool operator <(const bpq &q1, const bpq &q2) {
        return q1.root->value > q2.root->value;
    }

    static bpq merge(bpq &bpq1, bpq &bpq2) {
        if (bpq1.empty()) {
            bpq res = bpq(bpq2);
            return res;
        }
        if (bpq2.empty()) {
            bpq res = bpq(bpq1);
            return res;
        }
        if (bpq1.root->value < bpq2.root->value) {
            std::priority_queue<bpq> new_queue = bpq1.root->queue;
            new_queue.push(bpq2);
            return bpq(bpq1.root->value, new_queue);
        }
        std::priority_queue<bpq> new_queue = bpq2.root->queue;
        new_queue.push(bpq1);
        return bpq(bpq2.root->value, new_queue);
    }

    static bpq insert(bpq &bpq1, const int value) {
        return merge(bpq1, bpq(value));
    }

    static int get_min(bpq bpq1) {
        if (bpq1.empty()) {
            throw;
        }
        return bpq1.root->value;
    }

    static std::pair<int, bpq> extract_min(bpq bpq1) {
        if (bpq1.empty()) {
            throw;
        }
        if (bpq1.root->queue.empty()) {
            return std::make_pair(bpq1.root->value, bpq());
        }
        bpq min_bpq = bpq1.root->queue.top();
        std::priority_queue<bpq> new_queue(bpq1.root->queue);
        new_queue.pop();
        merge(min_bpq.root->queue, new_queue);
        if (min_bpq.empty()) {
            return std::make_pair(bpq1.root->value, bpq(min_bpq.root->value, new_queue));
        }
        return std::make_pair(bpq1.root->value, bpq(min_bpq.root->value, new_queue));
    }

private:
    struct node {
        int value;
        std::priority_queue<bpq> queue;
    };

    node *root = nullptr;

    static void merge(std::priority_queue<bpq> queue_from, std::priority_queue<bpq> &queue_to) {
        while (!queue_from.empty()) {
            queue_to.push(queue_from.top());
            queue_from.pop();
        }
    }
};



void test(bpq &q1) {
    std::pair<int, bpq> p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;
    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;
    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;

    p = bpq::extract_min(q1);
    std::cout << p.first << " ";
    q1 = p.second;
}

int main() {


    bpq q1 = bpq();

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
    q1.insert(-100);
    q1.insert(-20);
    q1.insert(40);
    q1.insert(50);
    q1.insert(45);


    bpq q2 = bpq(q1);
    q2.merge(q1);

    test(q1);
    std::cout << '\n';

    test(q2);
    test(q2);


    binomial_heap<int> bh = binomial_heap<int>();

    bh.insert(4);
    bh.insert(3);
    bh.insert(5);
    bh.insert(2);

    bh.insert(4);
    bh.insert(3);
    bh.insert(5);
    bh.insert(2);
    bh.insert(1);
    bh.insert(3);
    bh.insert(5);
    bh.insert(2);

    return 0;
}
