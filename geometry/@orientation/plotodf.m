function plotodf(o,varargin)
% Plot EBSD data at ODF sections
%
%% Input
%  ebsd - @EBSD
%
%% Options
%  SECTIONS   - number of plots
%  points     - number of orientations to be plotted
%  all        - plot all orientations
%  phase      - phase to be plotted
%
%% Flags
%  SIGMA (default)
%  ALPHA
%  GAMMA      
%  PHI1
%  PHI2
%
%% See also
% S2Grid/plot savefigure plot_index Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

cs = o.CS;
ss = o.SS;

% colorcoding
data = get_option(varargin,'property',[]);

% subsample to reduce size
if ~check_option(varargin,'all') && numel(o) > 2000 || check_option(varargin,'points')
  points = get_option(varargin,'points',2000);
  disp(['plot ', int2str(points) ,' random orientations out of ', ...
    int2str(numel(o)),' given orientations']);
  
  samples = discretesample(ones(1,numel(o)),points);
  o.rotation = o.rotation(samples);
  if ~isempty(data)
    data = data(samples); end
end

% reuse plot
if ishold && isappdata(gcf,'sections') && ...
    getappdata(gcf,'CS') == cs && getappdata(gcf,'SS') == ss
  
  sectype = getappdata(gcf,'SectionType');
  sec = getappdata(gcf,'sections');
  
else
  
  rmallappdata(gcf);
  hold off;
  sectype = get_flag(varargin,{'alpha','phi1','gamma','phi2','sigma'},'sigma');

  % get fundamental plotting region
  [max_rho,max_theta,max_sec] = getFundamentalRegion(cs,ss,varargin{:});

  if any(strcmp(sectype,{'alpha','phi1'}))
    dummy = max_sec; max_sec = max_rho; max_rho = dummy;
  end
  
  nsec = get_option(varargin,'SECTIONS',round(max_sec/degree/5));
  sec = linspace(0,max_sec,nsec+1); sec(end) = [];
  sec = get_option(varargin,sectype,sec,'double');
  varargin = [varargin,'maxrho',max_rho,'maxtheta',max_theta];
end

[symbol,labelx,labely] = sectionLabels(sectype);

%% generate plots

[S2G data]= project2ODFsection(o,sectype,sec,'data',data,varargin{:});
S2G = arrayfun(@(i) set(S2G{i},'res',get(S2G{1},'resolution')),1:numel(S2G),'uniformoutput',false);

%% ------------------------- plot -----------------------------------------
multiplot(@(i) S2G{i},@(i) data{i},length(sec),...
  'ANOTATION',@(i) [int2str(sec(i)*180/pi),'^\circ'],...
  'xlabel',labelx,'ylabel',labely,...
  'margin',0,'dynamicMarkerSize',...
  varargin{:});

setappdata(gcf,'sections',sec);
setappdata(gcf,'SectionType',sectype);
setappdata(gcf,'CS',cs);
setappdata(gcf,'SS',ss);
set(gcf,'Name',[sectype ' sections of "',get_option(varargin,'FigureTitle',inputname(1)),'"']);
