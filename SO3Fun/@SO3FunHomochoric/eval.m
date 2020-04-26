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

% find neighbouring points
% dist should be distance with respect to grid in x, y and z direction
[id, dx,dy,dz] = find(SO3F.S3G,ori,'cube');

% compute distances
[d,dist] = angle(ori,SO3F.S3G(id));

% perform trilinear interpolation 
% see https://www.wikiwand.com/en/Trilinear_interpolation

f = zeros(size(ori));    


end
