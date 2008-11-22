function plotipdf(ebsd,r,varargin)
% plot inverse pole figures
%
%% Input
%  ebsd - @EBSD
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

varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

[cs,ss] = getSym(ebsd);

if sum(sampleSize(ebsd))*length(cs)*length(ss) > 100000 || check_option(varargin,'points')
  
  points = fix(get_option(varargin,'points',100000/length(cs)/length(ss)));  
  disp(['plot ', int2str(points) ,' random orientations out of ', int2str(sum(sampleSize(ebsd))),' given orientations']);
  ebsd = subsample(ebsd,points);

end

% plotting grid
grid = getgrid(ebsd);
h = @(i) reshape(inverse(quaternion(ss * grid * cs)),[],1) * r(i);

[e1,maxtheta,maxrho] = getFundamentalRegion(cs,symmetry,varargin{:});
Sh = @(i) S2Grid(h(i),...
  'MAXTHETA',maxtheta,...
  'MAXRHO',maxrho,varargin{:});

multiplot(@(i) Sh(i),@(i) [],length(r),...
          'ANOTATION',@(i) r(i),...
          'dynamicMarkerSize', varargin{:});

set(gcf,'Name',['EBSD Pole Figure Scatter Plot of Specimen ',inputname(1)]);
