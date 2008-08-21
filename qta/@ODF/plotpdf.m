function plotpdf(odf,h,varargin)
% plot pole figures
%
%% Syntax
% plotpdf(odf,[h1,..,hN],<options>)
% plotpdf(odf,[h1,..,hN],'superposition',[c1,..,cN],<options>)
%
%% Input
%  odf - @ODF
%  h   - @Miller / @vector3d crystallographic directions
%  c   - structure coefficients
%
%% Options
%  RESOLUTION    - resolution of the plots 
%  SUPERPOSITION - plot superposed pole figures
%
%% Flags
%  REDUCED  - reduced pdf
%  COMPLETE - plot entire (hemi)-sphere
%
%% See also
% S2Grid/plot plot2all savefigure plot_index Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

argin_check(h,{'Miller','vector3d','cell'});
if isa(h,'Miller'), h = set(h,'CS',getSym(odf));end

% default options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

if iscell(h), h = [h{:}];end

% plotting grid
if check_option(varargin,'3d')
  r = S2Grid('PLOT',varargin{:});
else
  r = S2Grid('PLOT',...
    'MAXTHETA',rotangle_max_y(odf(1).SS,varargin{:})/2,...
    'MAXRHO',max(2*pi*check_option(varargin,'COMPLETE'),rotangle_max_z(odf(1).SS)),varargin{:});
end

if check_option(varargin,'superposition')
  multiplot(@(i) r,@(i) max(0,pdf(odf,h,r,varargin{:})),1,...
    'DISP',@(i,Z) [' PDF h=',char(h),...
    ' Max: ',num2str(max(Z(:))),...
    ' Min: ',num2str(min(Z(:)))],...
    'ANOTATION',@(i) h,...
    'MINMAX','SMOOTH',...
    varargin{:});
else
  multiplot(@(i) r,@(i) max(0,pdf(odf,h(i),r,varargin{:})),length(h),...
    'DISP',@(i,Z) [' PDF h=',char(h(i)),...
    ' Max: ',num2str(max(Z(:))),...
    ' Min: ',num2str(min(Z(:)))],...
    'ANOTATION',@(i) h(i),...
    'MINMAX','SMOOTH',...
    varargin{:});
end

name = inputname(1);
if isempty(name), name = odf(1).comment;end
set(gcf,'Name',['Pole figures of "',name,'"']);
