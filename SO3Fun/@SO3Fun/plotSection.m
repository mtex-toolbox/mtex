function plotSection(F,varargin)
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
%  smooth    - smooth plot
%  countourf - filled contour plot
%  contour   - contour lines
%  contour3, surf3, slice3 - 3d volume plot
%
% Example
%   % Section plots at specific angles
%   plotSection(SO3Fun.dubna,'phi2',[15,23,36]*degree)
%
% See also
% saveFigure Plotting

if F.antipodal, ap = {'antipodal'}; else, ap = {}; end
oS = newODFSectionPlot(F.CS,F.SS,ap{:},varargin{:});

S3G = oS.makeGrid('resolution',2.5*degree,varargin{:});

Z = real(F.eval(S3G,varargin{:}));
clear S3G

cR = [min(Z(:)),max(Z(:))];
if isempty(cR)
  cR = [0,1];
elseif cR(1) == cR(2)
  if cR(1) == 0
    cR(2) = 1;
  else
    cR(1) = 0;    
  end
end

oS.plot(Z,'smooth','colorRange',cR,varargin{:});
