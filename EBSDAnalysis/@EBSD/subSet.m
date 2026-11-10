function ebsd = subSet(ebsd,ind,varargin)
% indexing of EBSD data
%
% Syntax
%   subSet(ebsd,ind)
%

% a selection from a grid is a list that keeps the lattice, a block of
% subscripts, each varying along its own dimension only, stays a grid
isGrid = isa(ebsd,'EBSDgrid') || isa(ebsd,'EBSD3square');
sz = size(ebsd.id); subs = cell(size(sz));
if isGrid && ~islogical(ind), [subs{:}] = ind2sub(sz,ind); end
isBlock = @(d) all(subs{d} == mean(subs{d},setdiff(1:numel(sz),d)),'all');
toList = isGrid && ~check_option(varargin,'keepGrid') && (islogical(ind) || ...
  min(size(ind))==1 || ~all(arrayfun(isBlock,1:numel(sz))));

ebsd = subSet@dynProp(ebsd,ind);
ebsd.pos = ebsd.pos(ind);
ebsd.rotations = ebsd.rotations(ind);
ebsd.phaseId = reshape(ebsd.phaseId(ind),[],1);
ebsd.id = ebsd.id(ind);
if ~isempty(ebsd.A_D), ebsd.A_D = ebsd.A_D(ind(:),ind(:)); end

if toList && isa(ebsd,'EBSD3square')
  ebsd = EBSD3(ebsd);
elseif toList
  ebsd = EBSD(ebsd);
elseif isGrid
  % @dynProp hands a multi channel property back as one row per pixel, which
  % is the one shape that works for both storage layouts. This is still a
  % grid, so put the map shape back in front of the channels - reshape knows
  % how. Everything else is already the right shape and reshapes to itself.
  ebsd = reshape(ebsd,size(ebsd.id));
end
