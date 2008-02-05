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
% S2Grid/plot savefigure

global mtex_plot_options;
varargin = {varargin{:},mtex_plot_options{:}};

% plotting grid
if check_option(varargin,'3d')
  r = S2Grid('PLOT',varargin{:});
else
  r = S2Grid('PLOT',varargin{:},...
    'MAXTHETA',rotangle_max_y(odf(1).SS,varargin{:})/2,...
    'MAXRHO',max(2*pi*check_option(varargin,'COMPLETE'),rotangle_max_z(odf(1).SS)));
end

if check_option(varargin,'superposition')
  multiplot(@(i) r,@(i) pdf(odf,h,r,varargin{:}),1,...
    'DISP',@(i,Z) [' PDF h=',char(h),...
    ' Max: ',num2str(max(Z(:))),...
    ' Min: ',num2str(min(Z(:)))],...
    'ANOTATION',@(i) char(h,'LATEX'),...
    'MINMAX',...
    varargin{:},'SMOOTH');
else
  multiplot(@(i) r,@(i) pdf(odf,h(i),r,varargin{:}),length(h),...
    'DISP',@(i,Z) [' PDF h=',char(h(i)),...
    ' Max: ',num2str(max(Z(:))),...
    ' Min: ',num2str(min(Z(:)))],...
    'ANOTATION',@(i) char(h(i),'LATEX'),...
    'MINMAX',...
    varargin{:},'SMOOTH');
end

set(gcf,'Name',['Pole figures of "',inputname(1),'"']);
