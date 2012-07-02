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

%% make new plot

cs = o.CS;
ss = o.SS;

if newMTEXplot('ensureTag','pdf',...
    'ensureAppdata',{{'CS',cs},{'SS',ss}})
  argin_check(h,{'Miller'});
  h = ensureCS(get(o,'CS'),{h});
else
  h = getappdata(gcf,'h');
  options = getappdata(gcf,'options');
  if ~isempty(options), varargin = {options{:},varargin{:}};end
end

%% colorcoding
data = get_option(varargin,'property',[]);

%% get options
varargin = set_default_option(varargin,...
  getpref('mtex','defaultPlotOptions'));

if sum(numel(o))*length(cs)*length(ss) > 10000 || check_option(varargin,'points')

  points = fix(get_option(varargin,'points',10000/length(cs)/length(ss)));
  disp(['  plotting ', int2str(points) ,' random orientations out of ', int2str(numel(o)),' given orientations']);

  samples = discretesample(ones(1,numel(o)),points);
  o.rotation = o.rotation(samples);
  if ~isempty(data),
    data = data(samples);  end

end


%% plot
if check_option(varargin,'superposition')
  multiplot(@(i) reshape(ss * o * cs * h,[],1),@(i) [],1,...
    'ANOTATION',@(i) h,'dynamicMarkerSize',...
    'appdata',@(i) {{'h',h}},...
    varargin{:});
else
  r = @(i) reshape(ss * o * symmetrise(h(i)),[],1);

  [maxtheta,maxrho,minrho] = getFundamentalRegionPF(ss,varargin{:});
  Sr = @(i) S2Grid(r(i),'MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,'RESTRICT2MINMAX',varargin{:});

  Dr = @(i) repmat(reshape(data,1,[]),numel(symmetrise(h(i))),1);

  multiplot(@(i) Sr(i),...
    @(i) Dr(i),length(h),...
    'ANOTATION',@(i) h(i),'dynamicMarkerSize',...
    'appdata',@(i) {{'h',h(i)}},...
    varargin{:});
end

setappdata(gcf,'h',h);
setappdata(gcf,'SS',ss);
setappdata(gcf,'CS',cs);
setappdata(gcf,'options',extract_option(varargin,'antipodal'));
set(gcf,'Name',['Pole figures of "',get_option(varargin,'FigureTitle',inputname(1)),'"']);
set(gcf,'Tag','pdf');
