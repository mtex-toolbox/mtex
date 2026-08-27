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

% a numeric shift is added to x, y and z separately, so a 1 × 2 row expands them
if ~isa(v,'vector3d')
  error('MTEX:shift:invalidShift','An EBSD map can only be shifted by a vector3d.');
end

ebsd.pos = ebsd.pos + v;
