function res = inverse(o)
% inverse of a orientation

res = inverse@rotation(o);

if isa(res,'function_handle'), dbstop;end

[res.CS,res.SS] =  deal(res.SS,res.CS);
