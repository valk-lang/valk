
using System;
using System.Diagnostics;
using System.Threading.Tasks;
class ObjectCreation
{
    static Node keep;
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

    static void create_objects()
    {
        Node first = Node.Create(0);
        var watch = System.Diagnostics.Stopwatch.StartNew();
        int i = 10_000_000;
        while (i-- > 0)
        {
            Node n = Node.Create(0);
        }
        var ms = watch.ElapsedMilliseconds + 1;

        var process = Process.GetCurrentProcess();
        Console.WriteLine($"Created %amount objects in {ms} ms");
        Console.WriteLine("Verify: " + first.Check());
        Console.WriteLine("Memory usage : " + FormatBytes(process.WorkingSet64));
    }

    static void longlived_objects()
    {
        Node first = Node.Create(0);
        Node last = first;
        var watch = System.Diagnostics.Stopwatch.StartNew();
        int i = 10_000_000;
        while (i-- > 0)
        {
            Node n = Node.Create(0);
            last.next = n;
            last = n;
        }
        var ms = watch.ElapsedMilliseconds + 1;
        keep = first;

        var process = Process.GetCurrentProcess();
        Console.WriteLine($"Created %amount objects in {ms} ms");
        Console.WriteLine("Verify: " + first.Check());
        Console.WriteLine("Memory usage : " + FormatBytes(process.WorkingSet64));
    }

    static int verify_keep()
    {
        Node k = keep;
        if (k == null) return 0;
        return k.Check();
    }
    static void free_objects()
    {
        int check = verify_keep();
        var watch = System.Diagnostics.Stopwatch.StartNew();
        keep = null;
        GC.Collect();
        GC.Collect();
        var ms = watch.ElapsedMilliseconds + 1;

        var process = Process.GetCurrentProcess();
        Console.WriteLine($"Created %amount objects in {ms} ms");
        Console.WriteLine("Verify: " + check);
        Console.WriteLine("Memory usage : " + FormatBytes(process.WorkingSet64));
    }

    public static void Main(string[] args)
    {
        Console.Write("\n");
        create_objects();
        Console.Write("\n");
        longlived_objects();
        Console.Write("\n");
        free_objects();
        Console.Write("\n");
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
