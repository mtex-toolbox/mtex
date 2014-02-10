function plotipdf(odf,r,varargin)
% plot inverse pole figures
%
% Input
%  odf - @ODF
%  r   - @vector3d specimen directions
%
% Options
%  RESOLUTION - resolution of the plots
%
% Flags
%  antipodal    - include [[AxialDirectional.html,antipodal symmetry]]
%  COMPLETE - plot entire (hemi)--sphere
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

% make new plot
[ax,odf,r,varargin] = getAxHandle(odf,r,varargin{:});
if isempty(ax), newMTEXplot;end

argin_check(r,{'vector3d'});

% plotting grid
[minTheta,maxTheta,minRho,maxRho] = getFundamentalRegionPF(odf.CS,'restrict2Hemisphere',varargin{:});

h = plotS2Grid('minTheta',minTheta,'maxTheta',maxTheta,'maxRho',maxRho,'MINRHO',minRho,'RESTRICT2MINMAX',varargin{:});

% plot
disp(' ');
disp('Plotting inverse pole density function:')

multiplot(ax{:},length(r), h,...
  @(i) ensureNonNeg(pdf(odf,h,r(i)./norm(r(i)),varargin{:})),...
  'smooth','TR',@(i) r(i),varargin{:});

% finalize plot
if isempty(ax)
  setappdata(gcf,'r',r);
  setappdata(gcf,'CS',odf.CS);
  setappdata(gcf,'SS',odf.SS);
  set(gcf,'tag','ipdf');
  setappdata(gcf,'options',extract_option(varargin,'antipodal'));
  name = inputname(1);
  set(gcf,'Name',['Inverse Pole Figures of ',name]);


  % set data cursor
  dcm_obj = datacursormode(gcf);
  set(dcm_obj,'SnapToDataVertex','off')
  set(dcm_obj,'UpdateFcn',{@tooltip});

  datacursormode on;
end

end

% --------------- tooltip function ------------------------------
function txt = tooltip(varargin)

[r,h,value] = currentVector; %#ok<ASGLU>

txt = [xnum2str(value) ' at ' char(h,'tolerance',3*degree,'commasep')];

end

function [r,h,value] = currentVector

[pos,value,ax,iax] = getDataCursorPos(gcf);

CS = getappdata(gcf,'CS');
h = Miller(vector3d('polar',pos(1),pos(2)),CS);
h = round(h);
r = getappdata(gcf,'r');
r = r(iax);

projection = getappdata(ax,'projection');

if projection.antipodal
  r = set_option(r,'antipodal');
end

end
