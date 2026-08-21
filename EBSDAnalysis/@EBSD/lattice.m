function g = lattice(ebsd)
% the virtual lattice this EBSD's measurements sit on
%
% Computed on every access (like ebsd.orientations) rather than cached on
% the object - simplest to keep correct since pos/unitCell can change
% underneath it, at the cost of recomputing latticeBasis + the per-pixel
% index on each call. A caching option could be added later if this ever
% shows up as a bottleneck.
%
% This is the single canonical place that turns ebsd.unitCell + ebsd.pos
% into a lattice basis and a per-pixel integer index - previously
% reimplemented independently (and not always robustly) in gridIndex,
% gridComponents, spatialDecompositionGrid, generateUnitCells and calcMesh.
%
% Syntax
%   g = ebsd.lattice
%
% Output
%  g - struct with fields
%       A       - 2 x 2 lattice basis, columns are the grid step vectors
%       stencil - k x 2 integer neighbour offsets (k = 4 square, 6 hex)
%       dxy     - representative spacing = mean column norm of A
%       origin  - 1 x 2 physical position corresponding to ij = [0 0]
%       ij      - nEbsd x 2 integer lattice index of every pixel, robust
%                 to smooth (e.g. trapezoidal) grid distortion
%
% Note: ij is RELATIVE to this data's own extent. A phase subset therefore
% gets its own origin; do not compare indices across different subsets
% expecting a common frame.
%
% See also
% EBSD/latticeBasis EBSD/gridIndex

[A,stencil,dxy] = latticeBasis(ebsd.unitCell);

% A is in the map plane frame, so read the positions in the same frame
pos = ebsd.rot2Plane * ebsd.pos;
pos = [pos.x(:), pos.y(:)];
[ij,origin] = assignGridIndex(pos,A);

g = struct('A',A,'stencil',stencil,'dxy',dxy,'origin',origin,'ij',ij);

end
