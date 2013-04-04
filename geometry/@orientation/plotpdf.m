function plotpdf(o,h,varargin)
% plot pole figures
%
%% Syntax
% plotpdf(ori,[h1,..,hN],<options>)
%
%% Input
%  ori - @orientation
%  h   - @Miller crystallographic directions
%
%% Options
%  SUPERPOSITION - plot superposed pole figures
%  POINTS        - number of points to be plotted
%
%% Flags
%  antipodal    - include [[AxialDirectional.html,antipodal symmetry]]
%  COMPLETE - plot entire (hemi)--sphere
%
%% See also
% orientation/plotipdf S2Grid/plot savefigure
% Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

%% where to plot

[ax,o,h,varargin] = getAxHandle(o,h,varargin{:});

cs = o.CS;
ss = o.SS;

% for a new plot 
if ~isempty(ax) || newMTEXplot('ensureTag','pdf',...
    'ensureAppdata',{{'CS',cs},{'SS',ss}})
  
  % convert to cell
  if ~iscell(h), h = vec2cell(h);end 
  argin_check([h{:}],{'Miller'});  
  for i = 1:length(h)
    h{i} = ensureCS(get(o,'CS'),h(i));
  end  
else
  h = getappdata(gcf,'h');
  options = getappdata(gcf,'options');
  if ~isempty(options), varargin = {options{:},varargin{:}};end
end

%% colorcoding 1
data = get_option(varargin,'property',[]);

%% subsample if needed 

if ~check_option(varargin,'all') && ...
    (sum(numel(o))*length(cs)*length(ss) > 10000 || check_option(varargin,'points'))

  points = fix(get_option(varargin,'points',10000/length(cs)/length(ss)));
  disp(['  plotting ', int2str(points) ,' random orientations out of ', int2str(numel(o)),' given orientations']);
  disp('You can specify the the number points by the option "points".'); 
  disp('The option "all" ensures that all data are plotted');
  
  samples = discretesample(ones(1,numel(o)),points);
  o.rotation = o.rotation(samples);
  if ~isempty(data), data = data(samples); end
end

%% colorcoding 2
if check_option(varargin,'colorcoding')
  colorcoding = lower(get_option(varargin,'colorcoding','angle'));
  data = orientation2color(o,colorcoding,varargin{:});
end


%% plot

% compute specimen directions
sh = @(i) symmetrise(h{i});
r = @(i) reshape(ss * o * sh(i),[],1);

% symmetrise data
data = @(i) repmat(data(:).',[numel(ss) numel(sh(i))]);

[minTheta,maxTheta,minRho,maxRho] = getFundamentalRegionPF(ss,'restrict2Hemisphere',varargin{:});

multiplot(ax{:},numel(h),r,data,'scatter','TR',@(i) h(i),...  
  'minRho',minRho,'maxRho',maxRho,'minTheta',minTheta,'maxTheta',maxTheta,...
  varargin{:});

if isempty(ax)
  setappdata(gcf,'h',h);
  setappdata(gcf,'SS',ss);
  setappdata(gcf,'CS',cs);
  setappdata(gcf,'options',extract_option(varargin,'antipodal'));
  set(gcf,'Name',['Pole figures of "',get_option(varargin,'FigureTitle',inputname(1)),'"']);
  set(gcf,'Tag','pdf');
end
