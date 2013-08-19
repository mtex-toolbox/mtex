function  h = getFundamentalRegionRodrigues(cs,varargin)
% get the fundamental region for a crystal and specimen symmetry

[axes,angle] = getMinAxes(cs);

rot = rotation('axis',[axes,-axes],'angle',[angle,angle]./2);

h = Rodrigues(rot);

% v .* h <= norm(h)


