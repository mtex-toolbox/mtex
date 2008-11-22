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
%  REDUCED  - reduced pdf
%  COMPLETE - plot entire (hemi)-sphere
%
%% See also
% S2Grid/plot savefigure plot_index Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

argin_check(r,'vector3d');

% plotting grid
if check_option(varargin,'3d') 
  h = S2Grid('PLOT',varargin{:});  
else
  [e1,maxtheta,maxrho] = getFundamentalRegion(odf(1).CS,symmetry,varargin{:});
  h = S2Grid('PLOT',...
    'MAXTHETA',maxtheta,...
    'MAXRHO',maxrho,varargin{:});
end

multiplot(@(i) h,@(i) pdf(odf,h,r(i)./norm(r(i)),varargin{:}),length(r),...
  'DISP',@(i,Z) [' iPDF r=',char(r(i)),' Max: ',num2str(max(Z(:))),...
  ' Min: ',num2str(min(Z(:)))],...
  'ANOTATION',@(i) r(i),...
  'MINMAX','SMOOTH',...
  varargin{:});
setappdata(gcf,'vector3d',r);
setappdata(gcf,'CS',odf(1).CS);
setappdata(gcf,'SS',odf(1).SS);

name = inputname(1);
if isempty(name), name = odf(1).comment;end
set(gcf,'Name',['Inverse Pole Figures of ',name]);
