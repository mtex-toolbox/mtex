function p = basicHKL(cs,varargin)
% generate a list of Millers within for permutations of -n,0,n, 
% defaults to n = 1
%
% Input
%  cs  - symmetry
%
% Output
%  p   - list of Millers
%
% Options
%  maxhkl - maximum numeric value for h,k and l

n = get_option(varargin,'maxhkl',1);

[h,k,l] = meshgrid(-n:n);

p = Miller(h(:),k(:),l(:),cs);

p(isinf(p.dspacing)) = [];

if n>1 % eventually, this could be done more nicely
    pl = p(abs(p.h) > 1  | abs(p.k) > 1  | abs(p.l) > 1 );
    p1 = p(abs(p.h) <= 1 & abs(p.k) <= 1 & abs(p.l) <= 1);
    idc = abs(angle_outer(p1,pl))<1e-6; % those are doubles
    pl(any(idc)')=[];
    p = [p1;pl];
end

p = unique(p.symmetrise,'noSymmetry');
