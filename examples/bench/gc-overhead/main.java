
class app {

	public static void main(String[] args) {

		var repeat = 50;
		var object_count = 1_000_000;
		var list = Node.create(object_count);

		long startTime = System.nanoTime();
		var count = 0;
		while (count < repeat) {
			System.gc();
			count++;
		}
		long endTime = System.nanoTime();
		long ms = (endTime - startTime) / 1000000 + 1;

		System.out.println("> Finished " + count + " collections in " + ms + "ms.");
		System.out.println("> Collects per second: " + (repeat * 1000 / ms));
		System.out.println("> Verify: " + ((list.verify() == object_count + 1) ? "OK" : "FAIL"));
	}

	private static class Node {
		private Node next;

		private static Node create(int amount) {
			var i = 0;
			var prev = new Node(null);
			var first = prev;
			while (i++ < amount) {
				var n = new Node(null);
				prev.next = n;
				prev = n;
			}
			return first;
		}

		Node(Node next) {
			this.next = next;
		}

		private int verify() {
			var n = this;
			var c = 0;
			while (n != null) {
				n = n.next;
				c++;
			}
			return c;
		}
	}
}
