function f = eval(SO3F,ori,varargin)
% evaluate sum of unimodal components at orientation ori
%
% Syntax
%   f = SO3F.eval(g)
%
% Input
%  SO3F - @SO3FunHomochoric
%  ori  - @orientation
%
% Output
%  f - odf(ori)
%

% if isa(ori,'orientation')
%   ensureCompatibleSymmetries(SO3F,ori)
% end

% find neighbouring points
% get resolution of the grid
% values are the known function values on the grid points
[ind,dist] = find(SO3F.S3G,ori,'cube');
N = round(2 * pi / SO3F.S3G.res);
hres = pi^(2/3) / N;
values = SO3F.c;

% dist is distance downwards to grid in each coordinate
% calculate the related distance of the points (ori) to the grid 
% xd and yd and zd are those distances rounded downwards 
xd = dist(:,1) / hres;  yd = dist(:,2) / hres;  zd = dist(:,3) / hres; 

% perform trilinear interpolation 
% see https://www.wikiwand.com/en/Trilinear_interpolation 
c00 = values(ind(:,1)) .* (1-xd) + values(ind(:,5)) .* xd;
c01 = values(ind(:,2)) .* (1-xd) + values(ind(:,6)) .* xd;
c10 = values(ind(:,3)) .* (1-xd) + values(ind(:,7)) .* xd;
c11 = values(ind(:,4)) .* (1-xd) + values(ind(:,8)) .* xd;
c0  = c00 .* (1-yd) + c10 .* yd;
c1  = c01 .* (1-yd) + c11 .* yd;
f   = c0  .* (1-zd) + c1  .* zd;
 
end