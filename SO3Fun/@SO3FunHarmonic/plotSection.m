function plotSection(SO3F,varargin)
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
%  smooth    - smooth plot 
%  countourf - filled contour plot 
%  contour   - contour plot
%  contour3, surf3, slice3 - 3d volume plot
%
% Example
% % Section plots at specific angles
% plotSection(SO3Fun.dubna,'phi2',[15,23,36]*degree)
%
% See also
% saveFigure Plotting

if numel(SO3F)>1
  warning(['You try to plot an multivariate function. Plot the desired components ' ...
    'manually. In the following the first component is plotted.'])
  SO3F = SO3F.subSet(1);
end
if ~SO3F.isReal
  warning(['Imaginary part of complex valued SO3FunHarmonic is ignored. ' ...
    'In the following only the real part is plotted.'])
  SO3F.isReal=1;
end


if SO3F.antipodal, ap = {'antipodal'}; else, ap = {}; end
oS = newODFSectionPlot(SO3F.CS,SO3F.SS,ap{:},varargin{:});

% evaluate SO3F on the ODF-section grid
v = evalODFSections(SO3F,oS,'resolution',2.5*degree,varargin{:});

cR = [min(v(:)),max(v(:))];
if isempty(cR)
  cR = [0,1];
elseif cR(1) == cR(2)
  if cR(1) == 0
    cR(2) = 1;
  else
    cR(1) = 0;    
  end
end

oS.plot(v,'smooth','colorRange',cR,varargin{:});
