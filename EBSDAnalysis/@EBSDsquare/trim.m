function ebsd = trim(ebsd,ind)
% crop a map to the smallest rectangle containing all indexed data
%
% Syntax
%   ebsd = trim(ebsd)
%
%   % the smallest rectangle containing a mask
%   ebsd = trim(ebsd,~isnan(ebsd.bc))
%
% Input
%  ebsd - @EBSDsquare
%  ind  - logical mask or indices, by default ebsd.isIndexed
%
% Output
%  ebsd - @EBSDsquare
%
% Description
% Registering, rotating or masking a map leaves a border of points carrying
% no data. trim removes it. Points inside the rectangle are kept as they
% are, so notIndexed points enclosed by the data survive - in contrast to
% <EBSDsquare.subGrid.html |subGrid|>, which sets everything outside the
% mask to NaN.
%
% See also
% EBSDsquare/subGrid EBSD/subSet

if nargin == 1, ind = ebsd.isIndexed; end

if ~islogical(ind)
  isKeep = false(size(ebsd));
  isKeep(ind) = true;
else
  isKeep = reshape(ind,size(ebsd));
end

r = find(any(isKeep,2));
c = find(any(isKeep,1));

if isempty(r), error('MTEX:trim:empty','nothing to trim to - the mask is empty'); end

% trimming to the bounding rectangle is subGrid with nothing left to NaN
isKeep(:) = false;
isKeep(r(1):r(end),c(1):c(end)) = true;

ebsd = subGrid(ebsd,isKeep);

end
