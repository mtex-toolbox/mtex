function out = isCS(s)
% check if a symmetry is a crystal or specimen symmetry

out = numel(s.rotation)>4 || any(s.axis ~= [xvector,yvector,zvector]);
