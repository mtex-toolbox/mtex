function [ebsd,isNew] = addLatticeSites(ebsd)
% append a notIndexed measurement at every empty site of the ebsd's lattice
%
% What gridify does to make room for the missing pixels, without the matrix
% form: every site of the lattice index bounding box that carries no
% measurement gets a row with NaN rotation and NaN phaseId, positioned by
% the same deformation aware model spatialDecompositionGrid uses, so the new
% pixels follow a distorted grid rather than sitting on a rigid one.
%
% The NaN phaseId matches what squarify writes at its empty grid points, so
% both routes into fill/smooth see the same thing. Note the @EBSD copy
% constructor drops those rows again - EBSD(ebsd) is how you get rid of them.
%
% Syntax
%   [ebsd,isNew] = addLatticeSites(ebsd)
%
% Output
%  ebsd  - @EBSD, with the empty lattice sites appended
%  isNew - logical, true for the appended rows
%
% See also
% EBSD/fill EBSD/lattice EBSD/private/latticeModel EBSD/private/squarify

n = length(ebsd);
isNew = false(n,1);

g = ebsd.lattice;
ij = g.ij;

[~,ij2slot,ijMin,ijSize] = latticeLookup(ij);

% every site of the index bounding box - the same set squarify materialises
[ii,jj] = ndgrid(ijMin(1):ijMin(1)+ijSize(1)-1, ijMin(2):ijMin(2)+ijSize(2)-1);
IJ = [ii(:), jj(:)];

occupied = false(prod(ijSize),1);
occupied(ij2slot(ij)) = true;
IJnew = IJ(~occupied(ij2slot(IJ)),:);

m = size(IJnew,1);
if m == 0, return; end

% positions of the empty sites
pos = [ebsd.pos.x(:), ebsd.pos.y(:)];
isIndexed = ebsd.isIndexed(:);
if ~any(isIndexed), isIndexed = true(n,1); end   % nothing to fit against

reconstructPos = latticeModel(pos,ij,isIndexed,g.dxy);
xy = reconstructPos(IJnew);

% Keep only sites inside the scanned area. The index bounding box is a box
% in LATTICE coordinates, which for a hex grid - whose two axes are 60
% degree apart - is a rhombus in the plane, so its box contains a large
% wedge of sites that were never scanned. On titanium that was 12804 sites
% against gridify's 8148. For a square grid the two coincide and this
% removes nothing. The quarter step tolerance only absorbs rounding; it is
% well below the half step that would admit another ring.
ext = ebsd.extent;
tol = 0.25 * g.dxy;
inside = xy(:,1) >= ext(1)-tol & xy(:,1) <= ext(2)+tol & ...
         xy(:,2) >= ext(3)-tol & xy(:,2) <= ext(4)+tol;

IJnew = IJnew(inside,:);
xy = xy(inside,:);
m = size(IJnew,1);
if m == 0, return; end

posNew = vector3d(xy(:,1),xy(:,2),0);
posNew.how2plot = ebsd.pos.how2plot;

% the properties have to line up, so pad every field the same way squarify
% does - NaN for numeric/logical, the class's own nan for everything else
prop = struct;
for fn = fieldnames(ebsd.prop).'
  f = ebsd.prop.(char(fn));
  if isnumeric(f) || islogical(f)
    prop.(char(fn)) = nan(m,1);
  else
    prop.(char(fn)) = f.nan(m,1);
  end
end

pad = EBSD(posNew, rotation.nan(m,1), nan(m,1), ebsd.CSList, prop, ...
  'phaseMap', ebsd.phaseMap);

% explicit ids: cat resets EVERY id, noisily, if it sees a duplicate, and
% the EBSD constructor numbers the pad from 1. Counting from max(id) rather
% than from length: a subset such as ebsd('indexed') keeps the ids of the
% map it came from, so those are neither contiguous nor bounded by n.
pad.id = max([ebsd.id(:); 0]) + (1:m).';
pad.unitCell = ebsd.unitCell;
pad.scanUnit = ebsd.scanUnit;

ebsd = [ebsd; pad];
isNew = [isNew; true(m,1)];

end
