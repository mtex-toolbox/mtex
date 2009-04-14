function plotpdf(ebsd,h,varargin)
% plot pole figures
%
%% Syntax
% plotpdf(ebsd,[h1,..,hN],<options>)
% plotpdf(ebsd,[h1,..,hN],'superposition',[c1,..,cN],<options>)
%
%% Input
%  ebsd - @EBSD
%  h   - @Miller / @vector3d crystallographic directions
%  c   - structure coefficients
%
%% Options
%  RESOLUTION    - resolution of the plots 
%  SUPERPOSITION - plot superposed pole figures
%  POINTS        - number of points to be plotted
%
%% Flags
%  REDUCED  - reduced pdf
%  COMPLETE - plot entire (hemi)-sphere
%
%% See also
% EBSD/plotebsd S2Grid/plot savefigure
% plot_index Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

%% make new plot
grid = getgrid(ebsd,'checkPhase',varargin{:});
cs = get(grid,'CS');
ss = get(grid,'SS');
if newMTEXplot('ensureTag','pdf',...
    'ensureAppdata',{{'CS',cs},{'SS',ss}})
  argin_check(h,{'Miller'});  
else
  h = getappdata(gcf,'h');  
end

%% get options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

if sum(GridLength(grid))*length(cs)*length(ss) > 10000 || check_option(varargin,'points')
  
  points = fix(get_option(varargin,'points',10000/length(cs)/length(ss)));  
  disp(['plot ', int2str(points) ,' random orientations out of ', int2str(sum(GridLength(grid))),' given orientations']);
  grid = subsample(grid,points);

end


%% plot
if check_option(varargin,'superposition')
  multiplot(@(i) reshape(ss * grid * cs * h,[],1),@(i) [],1,...
    'ANOTATION',@(i) h,'dynamicMarkerSize',...
    'appdata',@(i) {{'h',h}},...
    varargin{:});
else
  multiplot(@(i) reshape(ss * grid * cs * h(i),[],1),...
    @(i) [],length(h),...
    'ANOTATION',@(i) h(i),'dynamicMarkerSize',...
    'appdata',@(i) {{'h',h(i)}},...
    varargin{:});  
end

setappdata(gcf,'h',h);
setappdata(gcf,'SS',ss);
setappdata(gcf,'CS',cs);
setappdata(gcf,'options',extract_option(varargin,'reduced'));
set(gcf,'Name',['Pole figures of "',inputname(1),'"']);
set(gcf,'Tag','pdf');
