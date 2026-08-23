function ebsd = subSet(ebsd,ind,varargin)
% indexing of EBSD data
%
% Syntax
%   subSet(ebsd,ind)
%

ebsd = subSet@dynProp(ebsd,ind);
ebsd.pos = ebsd.pos(ind);
ebsd.rotations = ebsd.rotations(ind);
ebsd.phaseId = reshape(ebsd.phaseId(ind),[],1);
ebsd.id = ebsd.id(ind);
if ~isempty(ebsd.A_D), ebsd.A_D = ebsd.A_D(ind(:),ind(:)); end

toList = isa(ebsd,'EBSDgrid') && ...
  ~check_option(varargin,'keepGrid') && ...
  (islogical(ind) || min(size(ind))==1);

if toList
  ebsd = EBSD(ebsd);
elseif isa(ebsd,'EBSDgrid')
  % @dynProp hands a multi channel property back as one row per pixel, which
  % is the one shape that works for both storage layouts. This is still a
  % grid, so put the map shape back in front of the channels - reshape knows
  % how. Everything else is already the right shape and reshapes to itself.
  ebsd = reshape(ebsd,size(ebsd.id));
end
