function o = inverse(o)

o.rotation = inverse(o.rotation);
[o.CS,o.SS] =  deal(o.SS,o.CS);
