function out = isCS(s)
% check if a symmetry is a crystal or specimen symmetry

out = numel(s.rotation)>4 || any(~isnull(norm(s.axis-[xvector,yvector,zvector])));
