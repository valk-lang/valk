
using System;
using System.Diagnostics;
using System.Threading.Tasks;

class GcOverhead
{
    class Node
    {
        public Node next;

        Node(Node next = null)
        {
            this.next = next;
        }

        internal static Node Create(int amount)
        {
            int i = 0;
            Node prev = new Node();
            Node first = prev;
            while (i++ < amount)
            {
                Node n = new Node();
                prev.next = n;
                prev = n;
            }
            return first;
        }

        internal int Check()
        {
            Node n = this;
            int c = 0;
            while (n != null)
            {
                n = n.next;
                c++;
            }

            return c;
        }

        internal void Hold() { }
    }

    public static void Main(string[] args)
    {
        int repeat = 50;
        int object_count = 1_000_000;
        Node list = Node.Create(object_count);

        var watch = System.Diagnostics.Stopwatch.StartNew();
        int count = 0;
        while (count < repeat)
        {
            GC.Collect();
            count++;
        }

        var ms = watch.ElapsedMilliseconds + 1;

        Console.WriteLine($"> Finished {count} collections in {ms}ms.");
        Console.WriteLine($"> Collects per second: " + (repeat * 1000 / ms));
        Console.WriteLine($"> Verify: " + ((list.Check() == object_count + 1) ? "OK" : "FAIL"));

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

        // Thread.Sleep(10000);
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
