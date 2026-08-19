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

% a numeric shift is added to each of x, y and z separately, so a 1 x 2 row
% implicitly expands the N x 1 coordinate arrays into N x 2 and silently
% returns a nonsensical object instead of a translation
if ~isa(v,'vector3d')
  error('MTEX:shift:invalidShift','An EBSD map can only be shifted by a vector3d.');
end

ebsd.pos = ebsd.pos + v;
