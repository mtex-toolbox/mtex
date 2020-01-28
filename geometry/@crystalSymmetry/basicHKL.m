function p = basicHKL(cs,varargin)
% plot symmetry
%
% Input
%  cs - symmetry
%
% Output
%
% Options
%  antipodal      - include <VectorsAxes.html antipodal symmetry>

[h,k,l] = meshgrid(-1:1);

p = Miller(h(:),k(:),l(:),cs);

p(isinf(p.dspacing)) = [];

p = unique(p.symmetrise,'noSymmetry');
