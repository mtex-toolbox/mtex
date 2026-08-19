function ebsd = reduce(ebsd,fak)
% reduce ebsd data by a factor
%
% Syntax
%   ebsd = reduce(ebsd)   % take every second pixel horiz. and vert.
%   ebsd = reduce(ebsd,3) % take every third pixel horiz. and vert.
%
% Input
%  ebsd    - @EBSD
%  factor  - resample ebsd at rate factor (integer)
%
% Output
%  ebsd    - @EBSD
%
% Description
% Keeps every fak-th site in both lattice directions. That sublattice is the
% same kind of lattice fak times coarser - square from a square grid,
% hexagonal from a hexagonal one - so the unit cell simply scales with fak.
%
% Selecting on the lattice index (see <EBSD.lattice.html |lattice|>) rather
% than on positions or on matrix subscripts is what makes one implementation
% cover every case: a plain list and a gridded map, a square and a hexagonal
% grid, and a grid that is rotated or otherwise not axis aligned. @EBSDhex
% used to override this with a version written on the staggered matrix
% subscripts, which could only ever express fak = 2 and rejected the second
% argument outright.
%
% See also
% EBSD/lattice EBSD/gridify

if nargin == 1, fak = 2; end

% a gridded map keeps its class, a list stays a list
wasGrid = isa(ebsd,'EBSDgrid');

ij = ebsd.lattice.ij;

ebsd = ebsd.subSet(all(mod(ij,fak) == 0, 2));
ebsd.unitCell = fak * ebsd.unitCell;

if wasGrid, ebsd = ebsd.gridify; end

end
