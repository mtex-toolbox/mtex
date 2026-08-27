function [ebsd,newId] = transformReferenceFrame(ebsd,gL)
% store a gridded map in a given matrix layout
%
% Syntax
%
%   ebsd = transformReferenceFrame(ebsd,gridLayout(yvector,xvector))
%   ebsd = transformReferenceFrame(ebsd,gridLayout(otherMap))
%   [ebsd,newId] = transformReferenceFrame(ebsd,gL)
%
% Input
%  ebsd - @EBSDsquare
%  gL   - @gridLayout the matrix indices are to advance along
%
% Output
%  ebsd  - @EBSDsquare, the same data reindexed
%  newId - where each element of the old matrix sits in the new one
%
% Description
% A gridded map has a layout of its own - the row index advances along d1
% and the column index along d2 - and this puts it into another one.
% Nothing is resampled and no value is invented: a transpose and two flips
% are all that is ever applied, so a layout no permutation can reach is
% approached as closely as one can, the same way <EBSD.gridify.html gridify>
% does.
%
% NB this changes the SHAPE of the map whenever the two layouts differ by a
% quarter turn - an r × c map comes back c × r.
%
% See also
% EBSD/gridify gridLayout/layoutIndex EBSDsquare/rotate

if min(size(ebsd)) < 2, newId = (1:numel(ebsd)).'; return; end

lin = layoutIndex(gL,[ebsd.d1 ebsd.d2],size(ebsd),'nearest');

if nargout > 1
  newId = zeros(numel(lin),1);
  newId(lin) = 1:numel(lin);
end

% 'keepGrid' because a permutation of a single scan line has min(size)==1,
% which subSet otherwise reads as a request for a plain list
if ~isequal(lin,reshape(1:numel(lin),size(lin)))
  ebsd = subSet(ebsd,lin,'keepGrid');
end

end
