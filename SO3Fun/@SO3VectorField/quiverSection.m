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
%  alpha     - alpha sections
%  sigma     - sigma = phi1 - phi2 sections
%  axisAngle - rotational angle sections
%  smooth
%  countourf
%  contour
%  contour3, surf3, slice3 - 3d volume plot
%
% See also
% saveFigure Plotting

oS = newODFSectionPlot(SO3VF.CS,SO3VF.SS,varargin{:});

% only plot the real part of SO3VF
% TODO: Add isReal for SO3VectorField
if isa(SO3VF,'SO3VectorFieldHarmonic')
  SO3VF.isReal = 1;
end

% TODO: Not completely implemented yet, see SO3FunHarmonic/plotSection
% if isa(SO3VF,'SO3VectorFieldHarmonic') && (isa(oS,'phi2Sections') || isa(oS,'phi1Sections') || isa(oS,'gammaSections'))
%   for c=1:3
%     [f(:,:,:,c),S3G0] = evalSectionsEquispacedFFT(SO3VF.SO3F(c),oS,'resolution',res,'shiftGrid',[1,1]*res/2,varargin{:});
%   end
%   f = permute(f,[2,1,3,4]);
%   S3G0 = permute(S3G0,[2,1,3]);
%   v = vector3d(f(:,:,:,1),f(:,:,:,2),f(:,:,:,3));
% else
  S3G0 = oS.quiverGrid('resolution',15*degree,varargin{:});
  v = reshape(SO3VF.eval(S3G0,varargin{:}),size(S3G0));
% end

if check_option(varargin,'normalize')
  v = normalize(v);
else
  v = v ./ max(norm(v(:)));
end
S3G1 = exp(S3G0,v/10000,SO3VF.tangentSpace);


oS.quiver(S3G0, S3G1,'noSymmetry',varargin{:},'all');
