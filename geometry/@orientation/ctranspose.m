function o = ctranspose(o)
% inverse of a orientation

o = ctranspose@rotation(o);
[o.CS,o.SS] =  deal(o.SS,o.CS);
