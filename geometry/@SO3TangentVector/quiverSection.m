function quiverSection(tV,varargin)
% plot SO3 tangential vector in section
%
% Syntax
%   N = vector3d.Z;
%   quiverSection(sVF1,v,N)
%   quiverSection(sVF1,sVF2,N,pi/3)
%
% Input
%  tV - @SO3TangentVector
%
% Options
%  lineWidth  -
%  color      -
%  normalized - draw unit length vectors
%  
%  sections  - number of sections
%  all       - plot all orientations
%  phi2      - phi2 sections (default)
%  phi1      - phi1 sections
%  gamma     - gamma sections
%  alpha     - alpha sections
%  sigma     - sigma = phi1 - phi2 sections
%  axisAngle - rotational angle sections
%
% See also
% saveFigure Plotting

ref = tV.oriRef;
oS = newODFSectionPlot(ref.CS,ref.SS,varargin{:});

if check_option(varargin,'normalize')
  tV = normalize(tV);
else
  tV = tV ./ max(norm(tV(:)));
end

oS.quiver(tV.rot, exp(tV/10000),'noSymmetry',varargin{:},'all');
