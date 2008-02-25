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
% S2Grid/plot savefigure

global mtex_plot_options;
varargin = {varargin{:},mtex_plot_options{:}};


cs = getSym(ebsd);

if sum(sampleSize(ebsd))*length(cs) > 100000 || check_option(varargin,'points')
  
  points = fix(get_option(varargin,'points',100000/length(cs)));  
  disp(['plot ', int2str(points) ,' random orientations out of ', int2str(sum(sampleSize(ebsd))),' given orientations']);
  ebsd = subsample(ebsd,points);

end

grid = getgrid(ebsd);
clear ebsd;

if check_option(varargin,'superposition')
  multiplot(@(i) reshape(grid * cs * h,[],1),@(i) 1,1,...
            'ANOTATION',@(i) char(h,'LATEX'),...
            varargin{:},'scatter');
else
  multiplot(@(i) reshape(grid * cs * h(i),[],1),...
            @(i) 1,length(h),...
            'ANOTATION',@(i) char(h(i),'LATEX'),...
            varargin{:},'scatter');
end

set(gcf,'Name',['Pole figures of "',inputname(1),'"']);
