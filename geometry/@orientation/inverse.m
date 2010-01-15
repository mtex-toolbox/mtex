function o = inverse(o)

o.quaternion = inverse(o.quaternion);
[o.cs,o.ss] =  deal(o.ss,o.cs);
