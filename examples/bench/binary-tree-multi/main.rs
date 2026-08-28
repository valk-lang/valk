use std::thread;

struct TreeNode {
    left: Option<Box<TreeNode>>,
    right: Option<Box<TreeNode>>,
}

struct TreeResult {
    iterations: usize,
    depth: i32,
    check: usize,
}

impl TreeNode {
    fn create(depth: i32) -> Box<TreeNode> {
        if depth == 0 {
            return Box::new(TreeNode {
                left: None,
                right: None,
            });
        }
        Box::new(TreeNode {
            left: Some(Self::create(depth - 1)),
            right: Some(Self::create(depth - 1)),
        })
    }

    fn check(&self) -> usize {
        match (&self.left, &self.right) {
            (Some(left), Some(right)) => 1 + left.check() + right.check(),
            _ => 1,
        }
    }
}

const MIN_DEPTH: i32 = 4;

fn check_depth(depth: i32, iterations: usize) -> TreeResult {
    let mut check = 0;
    for _ in 0..iterations {
        check += TreeNode::create(depth).check();
    }
    TreeResult {
        iterations,
        depth,
        check,
    }
}

fn main() {
    let requested_depth = std::env::args()
        .nth(1)
        .map(|value| value.parse().expect("invalid maximum depth"))
        .unwrap_or(5);
    let max_depth = requested_depth.max(MIN_DEPTH + 2);

    let stretch_depth = max_depth + 1;
    let stretch_check = TreeNode::create(stretch_depth).check();
    println!(
        "stretch tree of depth {}\t check: {}",
        stretch_depth, stretch_check
    );

    let long_lived = TreeNode::create(max_depth);
    thread::scope(|scope| {
        let handles: Vec<_> = (MIN_DEPTH..=max_depth)
            .step_by(2)
            .map(|depth| {
                let iterations = 1usize << (max_depth - depth + MIN_DEPTH) as u32;
                scope.spawn(move || check_depth(depth, iterations))
            })
            .collect();

        for handle in handles {
            let result = handle.join().expect("binary-tree worker panicked");
            println!(
                "{}\t trees of depth {}\t check: {}",
                result.iterations, result.depth, result.check
            );
        }
    });

    println!(
        "long lived tree of depth {}\t check: {}",
        max_depth,
        long_lived.check()
    );
}
