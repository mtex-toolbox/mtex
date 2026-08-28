function out = isMisorientation(o)
% check whether o is a misorientation

out = isa(o.SS,'crystalFrame') && isa(o.CS,'crystalFrame');
