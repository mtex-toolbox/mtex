function  h = getFundamentalRegionRodriguez(cs,varargin)
% get the fundamental region for a crystal and specimen symmetry

ax = axis(cs);
an = angle(cs) ./ 2;

rot = rotation('axis',ax(2:end),'angle',an(2:end));

h = Rodrigues(rot);


% v .* h <= norm(h)