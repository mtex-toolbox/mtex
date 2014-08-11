function out = isMisorientation(o)
% check whether o is a misorientation

out = isa(o.SS,'crystalSymmetry') && isa(o.CS,'crystalSymmetry');
