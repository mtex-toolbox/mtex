function out = isPerp(v1,v2)
% check whether v1 and v2 are orthogonal

out = isnull(dot(v1,v2));
