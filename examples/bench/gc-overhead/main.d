
import std.datetime.stopwatch;
import core.memory;
import std.stdio;

struct Node {
    Node* next;

    int verify() {
        if (this.next == null) {
            return 1;
        }
        return 1 + this.next.verify();
    }
}

Node* createObjects(int amount) {
    Node* prev = new Node();
    Node* first = prev;
    for (int i = 0; i < amount; i++) {
        Node* n = new Node();
		prev.next = n;
		prev = n;
    }
	return first;
}

void main() {

    writeln("# Create objects");

    auto repeat = 50;
    auto object_count = 500 * 1000;
    auto list = createObjects(object_count);

    writeln("# Start");
    auto start = MonoTime.currTime;

    // Force the garbage collector to run
    for (int i = 0; i < repeat; i++) {
        GC.collect();
    }

    auto end = MonoTime.currTime;
    auto duration = end - start;
    writeln("# Done");

    double ms = duration.total!"msecs" + (duration.total!"usecs" % 1000) / 1000.0;
    writeln("> Finished ", repeat, " collections in ", ms, " ms");
    writeln("> Collects per second: ", repeat * 1000 / ms);
    writeln("> Verify: ", (list.verify() == object_count + 1) ? "OK" : "FAIL");
}
