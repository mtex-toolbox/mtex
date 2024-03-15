function ebsd = plus(ebsd,v)
% shift ebsd by vector3d
%
% Syntax
%
%   % shift in x direction
%   ebsd = ebsd + 100*vector3d.X
%
% Input
%  ebsd - @EBSD
%  v - @vector3d shift
%
% Output
%  ebsd - @EBSD

if isa(v,'EBSD'), [v,ebsd] = deal(ebsd,v); end

ebsd.pos = ebsd.pos + v;