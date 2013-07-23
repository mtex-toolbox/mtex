function o = ctranspose(o)

o.rotation = ctranspose(o.rotation);
[o.CS,o.SS] =  deal(o.SS,o.CS);
