function plotipdf(odf,r,varargin)
% plot inverse pole figures
%
%% Input
%  odf - @ODF
%  r   - @vector3d specimen directions
%
%% Options
%  RESOLUTION - resolution of the plots
%
%% Flags
%  antipodal    - include [[AxialDirectional.html,antipodal symmetry]]
%  COMPLETE - plot entire (hemi)--sphere
%
%% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

%% make new plot
[ax,odf,r,varargin] = getAxHandle(odf,r,varargin{:});
if isempty(ax), newMTEXplot;end

argin_check(r,{'vector3d'});

%% plotting grid
[minTheta,maxTheta,minRho,maxRho] = getFundamentalRegionPF(odf(1).CS,'restrict2Hemisphere',varargin{:});

h = S2Grid('PLOT','minTheta',minTheta,'MAXTHETA',maxTheta,'MAXRHO',maxRho,'MINRHO',minRho,'RESTRICT2MINMAX',varargin{:});

%% plot
disp(' ');
disp('Plotting inverse pole density function:')

multiplot(ax{:},numel(r), h,...
  @(i) ensureNonNeg(pdf(odf,h,r(i)./norm(r(i)),varargin{:})),...
  'smooth','TR',@(i) r(i),varargin{:});

%% finalize plot
if isempty(ax)
  setappdata(gcf,'r',r);
  setappdata(gcf,'CS',odf(1).CS);
  setappdata(gcf,'SS',odf(1).SS);
  set(gcf,'tag','ipdf');
  setappdata(gcf,'options',extract_option(varargin,'antipodal'));
  name = inputname(1);
  if isempty(name), name = odf(1).comment;end
  set(gcf,'Name',['Inverse Pole Figures of ',name]);


  %% set data cursor
  dcm_obj = datacursormode(gcf);
  set(dcm_obj,'SnapToDataVertex','off')
  set(dcm_obj,'UpdateFcn',{@tooltip});

  datacursormode on;
end


%% Tooltip function
function txt = tooltip(empt,eventdata) %#ok<INUSL>

pos = get(eventdata,'Position');
xp = pos(1); yp = pos(2);

rho = atan2(yp,xp);
rqr = xp^2 + yp^2;
theta = acos(1-rqr/2);

m = Miller(vector3d('polar',theta,rho),getappdata(gcf,'CS'));

txt = char(m,'tolerance',3*degree);