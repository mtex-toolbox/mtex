function o = inv(o)
% inverse of an orientation

o = inv@rotation(o);

[o.CS,o.SS] =  deal(o.SS,o.CS);
