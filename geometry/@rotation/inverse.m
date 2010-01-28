function o = inverse(o)

o.quaternion = inverse(o.quaternion);
[o.CS,o.SS] =  deal(o.SS,o.CS);
