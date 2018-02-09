function p = basicHKL(cs,varargin)
% plot symmetry
%
% Input
%  cs - symmetry
%
% Output
%
% Options
%  antipodal      - include [[AxialDirectional.html,antipodal symmetry]]

[h,k,l] = meshgrid(-1:1);

p = Miller(h,k,l,cs);

d = p.dspacing;

p(isinf(d)) = [];
d(isinf(d)) = [];

p = p.symmetrise('unique');
