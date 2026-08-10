function varargout = gridify(ebsd,varargin)
% extend EBSD data to an grid
%
% Description This function transforms unordered EBSD data sets into a
% matrix shaped regular grid. No interpolation is done hereby. Grid points
% in the regular grid that do not have a correspondence in the regular grid
% are set to NaN. Having the EBSD data in matrix form has several
% advantages:
%
% * the data can be handed to image processing and registration tools as a
%   matrix, and ebsd(i,j) addresses a scan position
% * much faster visualization of big maps
% * much faster computation of the kernel average misorientation
%
% It is no longer required for <OrientationGradient.html gradient>,
% <EBSD.curvature.html curvature>, <EBSD.calcGND.html GND> or the gradient
% method of <EBSD.weightedBurgersVec.html weightedBurgersVec> - those are
% computed on the virtual lattice (see <EBSD.lattice.html lattice>) and work
% on a plain @EBSD, on a phase subset, and on rotated or sheared grids. The
% integral method of weightedBurgersVec and <EBSD.smooth.html denoising> are
% raster algorithms and still gridify internally.
%
% Syntax
%   [ebsdGrid,newId] = gridify(ebsd)
%   [ebsdGrid,newId] = gridify(ebsd,'unitCell',unitCell)
%   [ebsdGrid,newId] = gridify(ebsd,'rowMajor')
%
% Input
%  ebsd - an @EBSD data set with a non regular grid
%
% Output
%  ebsd - @EBSDsquare, @EBSDhex data on a regular grid
%  newId - closest regular grid point for every non regular grid point
%
% Options
%  extent - extend of gridded map
%  unitCell - unit cell of the gridded map
%
% Flags
%  columnMajor - one scan row per matrix row, i.e. size(ebsd) = [numRows numCols] (default)
%  rowMajor    - the transposed layout, i.e. size(ebsd) = [numCols numRows]
%
% Description of the layout
% In the default column major layout the first dimension of the resulting
% matrix is the grid direction closest to y and the second one the grid
% direction closest to x, both oriented such that the coordinates increase.
% Accordingly |ebsd(i,j)| is the j-th pixel of the i-th scan row and
% |ebsd(1,1)| is the corner with the smallest coordinates. Hexagonal grids
% are always stored this way, the flags apply to square grids only.
%
% Example
%
%   mtexdata twins
%   ebsdMg = ebsd('Magnesium').gridify 
%   plot(ebsdMg, ebsdMg.orientations)
%

% extract new unitCell
unitCell = get_option(varargin,'unitCell',ebsd.unitCell);

if length(unitCell) == 6
  % a hexagonal grid encodes the alternating offset of its lines in the
  % matrix layout, hence there is no choice to be made here
  if check_option(varargin,'rowMajor')
    warning('MTEX:gridify:rowMajor',...
      'A hexagonal grid is always stored column major - ignoring the flag ''rowMajor''.');
  end
  [varargout{1:nargout}] = hexify(ebsd,varargin{:});
else
  [varargout{1:nargout}] = squarify(ebsd,varargin{:});
end

end
