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
% S2Grid/plot savefigure


% plotting grid
h = @(i) reshape(inverse(quaternion(getgrid(ebsd))),[],1)*r(i);

Sh = @(i) S2Grid(h(i),varargin{:},...
  'MAXTHETA',rotangle_max_y(getSym(ebsd),varargin{:})/2,...
  'MAXRHO',max(2*pi*check_option(varargin,'COMPLETE'),...
  rotangle_max_z(getSym(ebsd),varargin{:})));

multiplot(@(i) Sh(i),@(i) 1,length(r),...
          'ANOTATION',@(i) char(r(i),'LATEX'),...
          'scatter', varargin{:});

set(gcf,'Name',['recalculated Pole Figures of Specimen ',inputname(1)]);
figure(gcf)

