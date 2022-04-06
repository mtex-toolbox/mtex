function plotSection(odf,varargin)
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
%  contour   - contour plot
%  contour3, surf3, slice3 - 3d volume plot
%
% See also
% saveFigure Plotting

if odf.antipodal, ap = {'antipodal'}; else, ap = {}; end
oS = newODFSectionPlot(odf.CS,odf.SS,ap{:},varargin{:});

S3G = oS.makeGrid('resolution',2.5*degree,varargin{:});

Z = odf.eval(S3G);
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
