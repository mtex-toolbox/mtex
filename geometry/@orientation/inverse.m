function o = inverse(o)
% inverse of a orientation

o = inverse@rotation(o);

[o.CS,o.SS] =  deal(o.SS,o.CS);
