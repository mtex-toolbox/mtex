function plotAxisDistribution(odf,varargin)
% plot axis distribution
%
%% Input
%  odf - @ODF
%
%% Options
%  RESOLUTION - resolution of the plots
%
%% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%  COMPLETE  - plot entire (hemi)--sphere
%
%% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo


varargin = set_default_option(varargin,...
  getpref('mtex','defaultPlotOptions'));

%% make new plot
newMTEXplot;

%% plotting grid

[maxtheta,maxrho,minrho] = getFundamentalRegionPF(disjoint(odf(1).CS,odf(1).SS),'antipodal',varargin{:});
h = S2Grid('PLOT','MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,'RESTRICT2MINMAX','antipodal',varargin{:});


%% plot
multiplot(@(i) h,@(i) pos(calcAxisDistribution(odf,h,varargin{:})),1,...
  'MINMAX','SMOOTH',varargin{:});

setappdata(gcf,'CS',odf(1).CS);
setappdata(gcf,'SS',odf(1).SS);
set(gcf,'tag','AxisDistribution');
setappdata(gcf,'options',extract_option(varargin,'antipodal'));
name = inputname(1);
if isempty(name), name = odf(1).comment;end
set(gcf,'Name',['Axis Distribution of ',name]);

function d = pos(d)

if min(d(:)) > -1e-5, d = max(d,0);end
