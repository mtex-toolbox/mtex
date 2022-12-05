function quiverSection(SO3VF,varargin)
% plot a vector field along another vectorfield
%
% Syntax
%
%   N = vector3d.Z;
%   quiverSection(sVF1,v,N)
%   quiverSection(sVF1,sVF2,N,pi/3)
%
% Input
%  sVF1, sVF2 - @S2VectorField
%  v - @vector3d
%  N - normal @vector3d of the section
%
% Options
%  normalized - draw unit length vectors

% plot ODF sections
%
% Options
%  sections - number of sections
%  points   - number of orientations to be plotted
%  all      - plot all orientations
%  resolution - resolution of each plot
%
% Flags
%  phi2      - phi2 sections (default)
%  phi1      - phi1 sections
%  gamma     - gamma sections
%  sigma     - sigma = phi1 - phi2 sections
%  axisAngle - rotational angle sections
%  smooth
%  countourf
%  contour
%  contour3, surf3, slice3 - 3d volume plot
%
% See also
% saveFigure Plotting

if SO3VF.antipodal, ap = {'antipodal'}; else, ap = {}; end
oS = newODFSectionPlot(SO3VF.CS,SO3VF.SS,ap{:},varargin{:});

S3G0 = oS.quiverGrid('resolution',15*degree,varargin{:});

v = reshape(SO3VF.eval(S3G0,varargin{:}),size(S3G0));

if check_option(varargin,'normalize')
  v = normalize(v);
else
  v = v ./ max(norm(v(:)));
end
S3G1 = exp(S3G0,v/10000);


oS.quiver(S3G0, S3G1,'noSymmetry',varargin{:});
