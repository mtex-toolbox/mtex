function varargout = plot(o,varargin)
% plot function
%
%% Input
%  o - @orientation
%
%% Options
%  RODRIGUES - plot in rodrigues space
%  AXISANGLE - plot in axis / angle
%
%% See also

%% two dimensional plot -> S2Grid/plot

if ~(ishold && strcmp(get(gca,'tag'),'ebsd_raster')) && ...  
  ~check_option(varargin,{'scatter','rodrigues','axisangle'}) 

  if numel(o) == 1
  
    h = [Miller(1,0,0),Miller(0,1,0),Miller(0,0,1)];
    plot(o * h,'label',...
      {char(h(1),'Latex'),char(h(2),'Latex'),char(h(3),'Latex')},...
      varargin{:});
  
  else % plot as pdfs
  
    h = [Miller(1,0,0),Miller(0,1,0),Miller(0,0,1)];
      
    multiplot(@(i) S2Grid(o .* h(i)),@(i) [],numel(h),...
      'ANOTATION',@(i) h(i),...
      'appdata',@(i) {{'h',h}},...
      varargin{:});
     
  end
  
else % scatter plot
  
  scatter(o,varargin{:});
  
end
