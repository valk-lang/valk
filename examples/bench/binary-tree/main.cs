
using System;
using System.Diagnostics;
using System.Threading.Tasks;

class BinaryTrees
{
    class TreeNode
    {
        public TreeNode left;
        public TreeNode right;

        TreeNode(TreeNode left = null, TreeNode right = null)
        {
            this.left = left;
            this.right = right;
        }

        internal static TreeNode Create(int d)
        {
            return d == 0 ? new TreeNode()
                          : new TreeNode(Create(d - 1), Create(d - 1));
        }

        internal int Check()
        {
            int c = 1;
            if (right != null)
            {
                c += right.Check();
            }
            if (left != null)
            {
                c += left.Check();
            }
            return c;
        }

        internal void Hold() { }
    }

    const int MinDepth = 4;
    public static void Main(string[] args)
    {
        var maxDepth = args.Length == 0 ? 10
            : Math.Max(MinDepth + 2, int.Parse(args[0]));

        var stretchDepth = maxDepth + 1;
        Console.WriteLine($"stretch tree of depth {stretchDepth}\t check: {TreeNode.Create(stretchDepth).Check()}");

        var longLivedTree = TreeNode.Create(maxDepth);
        var nResults = (maxDepth - MinDepth) / 2 + 1;
        for (int i = 0; i < nResults; i++)
        {
            var depth = i * 2 + MinDepth;
            var n = (1 << maxDepth - depth + MinDepth);

            var check = 0;
            for (int j = 0; j < n; j++)
            {
                check += TreeNode.Create(depth).Check();
            }

            Console.WriteLine($"{n}\t trees of depth {depth}\t check: {check}");
        }

        Console.WriteLine($"long lived tree of depth {maxDepth}\t check: {longLivedTree.Check()}");

        var process = Process.GetCurrentProcess();

        long peakWS = process.PeakWorkingSet64;
        long peakPriv = process.PeakVirtualMemorySize64;  // ← alternative (virtual)

        Console.WriteLine();
        Console.WriteLine("Peak physical memory (Working Set) : "
            + FormatBytes(peakWS));
        Console.WriteLine("Peak virtual memory                 : "
            + FormatBytes(peakPriv));
        Console.WriteLine();
        Console.WriteLine("(for comparison — current values)");
        Console.WriteLine("Current Working Set                 : "
            + FormatBytes(process.WorkingSet64));
        Console.WriteLine("Current Private Bytes               : "
            + FormatBytes(process.PrivateMemorySize64));
    }
    static string FormatBytes(long bytes)
    {
        string[] suf = { "B", "KB", "MB", "GB", "TB", "PB", "EB" };
        if (bytes == 0) return "0 " + suf[0];
        long bytesAbs = Math.Abs(bytes);
        int place = Convert.ToInt32(Math.Floor(Math.Log(bytesAbs, 1024)));
        double num = Math.Round(bytesAbs / Math.Pow(1024, place), 2);
        return (Math.Sign(bytes) * num).ToString() + " " + suf[place];
    }
}
