function plotodf(o,varargin)
% Plot EBSD data at ODF sections
%
% Input
%  ebsd - @EBSD
%
% Options
%  SECTIONS   - number of plots
%  points     - number of orientations to be plotted
%  all        - plot all orientations
%  phase      - phase to be plotted
%
% Flags
%  SIGMA (default) -
%  OMEGA - sections along crystal directions @Miller
%  ALPHA -
%  GAMMA -
%  PHI1 -
%  PHI2 -
%  AXISANGLE -
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

% where to plot
[ax,o,varargin] = getAxHandle(o,varargin{:});

cs = o.CS;
ss = o.SS;

% colorcoding
data = get_option(varargin,'property',[]);

% subsample to reduce size
if ~check_option(varargin,'all') && length(o) > 2000 || check_option(varargin,'points')
  points = fix(get_option(varargin,'points',2000));
  disp(['  plotting ', int2str(points) ,' random orientations out of ', ...
    int2str(length(o)),' given orientations']);

  samples = discretesample(ones(1,length(o)),points);
  o= o.subSet(samples);
  if ~isempty(data)
    data = data(samples); end
end

% determine section type

sectype = get_flag(varargin,{'alpha','phi1','gamma','phi2','sigma','omega','axisangle'},'phi2');
[symbol,labelx,labely] = sectionLabels(sectype);

if any(strcmpi(sectype,{'sigma','omega','axisangle'}))
  varargin = [{'innerPlotSpacing',10},varargin];
else
  varargin = [{'projection','plain',...
    'xAxisDirection','east','zAxisDirection','intoPlane',...
    'innerPlotSpacing',35,'outerPlotSpacing',35},varargin];
end

% get fundamental plotting region
[max_rho,max_theta,max_sec] = getFundamentalRegion(cs,ss,varargin{:});

if any(strcmp(sectype,{'alpha','phi1'}))
  dummy = max_sec; max_sec = max_rho; max_rho = dummy;
elseif strcmpi(sectype,'omega')
  max_sec = 2*pi;
end

nsec = get_option(varargin,'SECTIONS',round(max_sec/degree/5));
sec = linspace(0,max_sec,nsec+1); sec(end) = [];
sec = get_option(varargin,sectype,sec,'double');

% maybe I should reuse a plot
if isempty(ax) && ~newMTEXplot('ensureappdata',...
    {{'sections',[]},{'CS',cs},{'SS',ss}})
  
  %'xlabel',labelx,'ylabel',labely
  
    sectype = getappdata(gcf,'SectionType');
    sec = getappdata(gcf,'sections');
    nsec = length(sec);
    
  if strcmpi(sectype,'omega')
    varargin = set_default_option(varargin,{getappdata(gcf,'h')});
  end
     
else
  
  varargin = [varargin,'maxrho',max_rho,'maxtheta',max_theta];  
  
end


% generate plots
[S2G, data]= project2ODFsection(o,sectype,sec,'data',data,varargin{:});

%ensure equal resolution for all plots
for i = 1:length(S2G), S2G{i}.resolution = S2G{1}.resolution; end

% ------------------------- plot -----------------------------------------
multiplot(ax{:},nsec,@(i) S2G{i},@(i) data{i},...
  'TR',@(i) [int2str(sec(i)*180/pi),'^\circ'],...
  'xlabel',labelx,'ylabel',labely,'dynamicMarkerSize',varargin{:}); %#ok<*EVLC>

if isempty(ax)
  setappdata(gcf,'sections',sec);
  setappdata(gcf,'SectionType',sectype);
  setappdata(gcf,'CS',cs);
  setappdata(gcf,'SS',ss);
  set(gcf,'Name',[sectype ' sections of "',get_option(varargin,'FigureTitle',inputname(1)),'"']);
  set(gcf,'tag','odf')

  if strcmpi(sectype,'omega') && ~isempty(find_type(varargin,'Miller'))
    h = varargin{find_type(varargin,'Miller')};
    setappdata(gcf,'h',h);
  end
end

