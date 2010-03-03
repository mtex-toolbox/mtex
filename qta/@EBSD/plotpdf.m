function plotpdf(ebsd,h,varargin)
% plot pole figures
%
%% Syntax
% plotpdf(ebsd,[h1,..,hN],<options>)
%
%% Input
%  ebsd - @EBSD
%  h    - @Miller crystallographic directions
%
%% Options
%  SUPERPOSITION - plot superposed pole figures
%  POINTS        - number of points to be plotted
%
%% Flags
%  antipodal    - include [[AxialDirectional.html,antipodal symmetry]]
%  COMPLETE - plot entire (hemi)-sphere
%
%% See also
% EBSD/plotebsd S2Grid/plot savefigure
% plot_index Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

%% make new plot
o = get(ebsd,'orientations','checkPhase',varargin{:});
cs = get(o,'CS');
ss = get(o,'SS');
if newMTEXplot('ensureTag','pdf',...
    'ensureAppdata',{{'CS',cs},{'SS',ss}})
  argin_check(h,{'Miller'});
  h = set(h,'CS',get(ebsd,'CS'));
else
  h = getappdata(gcf,'h');
  options = getappdata(gcf,'options');
  if ~isempty(options), varargin = {options{:},varargin{:}};end
end

%% get options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

if sum(numel(o))*length(cs)*length(ss) > 10000 || check_option(varargin,'points')

  points = fix(get_option(varargin,'points',10000/length(cs)/length(ss)));
  disp(['plot ', int2str(points) ,' random orientations out of ', int2str(numel(o)),' given orientations']);
  o = o(discretesample(ones(1,numel(o)),points));

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

  multiplot(@(i) Sr(i),...
    @(i) [],length(h),...
    'ANOTATION',@(i) h(i),'dynamicMarkerSize',...
    'appdata',@(i) {{'h',h(i)}},...
    varargin{:});
end

setappdata(gcf,'h',h);
setappdata(gcf,'SS',ss);
setappdata(gcf,'CS',cs);
setappdata(gcf,'options',extract_option(varargin,'antipodal'));
set(gcf,'Name',['Pole figures of "',inputname(1),'"']);
set(gcf,'Tag','pdf');
