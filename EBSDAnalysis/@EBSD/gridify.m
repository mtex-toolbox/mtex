function varargout = gridify(ebsd,varargin)
% extend EBSD data to an grid
%
% Description This function transforms unordered EBSD data sets into a
% matrix shaped regular grid. No interpolation is done herby. Grid points
% in the regular grid that do not have a correspondence in the regular grid
% are set to NaN. Having the EBSD data in matrix form has several
% advantages:
%
% * required for <OrientationGradient.html gradient>,
% <EBSDsquare.curvature.html curvature> and <GND> computation
% * much faster visualisation of big maps
% * much faster computation of the kernel average misorientation
%
% Syntax
%   [ebsdGrid,newId] = gridify(ebsd)
%   [ebsdGrid,newId] = gridify(ebsd,'unitCell',unitCell)
%
% Input
%  ebsd - an @EBSD data set with a non regular grid
%
% Output
%  ebsd - @EBSDsquare, @EBSDhex data on a regular grid
%  newId - closest regular grid point for every non regular grid point
%
% Example
%
%   mtexdata twins
%   ebsdMg = ebsd('Magnesium').gridify 
%   plot(ebsdMg, ebsdMg.orientations)
%

% extract new unitCell
unitCell = get_option(varargin,'unitCell',ebsd.unitCell);

if size(unitCell,1) == 6
  [varargout{1:nargout}] = hexify(ebsd,varargin{:});
else
  [varargout{1:nargout}] = squarify(ebsd,varargin{:});
end

end
