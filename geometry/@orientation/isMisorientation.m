function out = isMisorientation(o)
% check whether o is a misorientation

out = isCS(o.SS) && isCS(o.CS);
