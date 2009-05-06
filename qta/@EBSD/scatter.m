function scatter(ebsd,varargin)
% plots ebsd data as scatter plot
%
%% Syntax
% scatter(ebsd,<options>)
%
%% Input
%  ebsd - @EBSD
%
%% Options
%  AXISANGLE     - axis angle projection
%  RODRIGUES     - rodrigues parameterization
%  POINTS        - number of orientations to be plotted
%  CENTER        - orientation center
%
%% See also
% EBSD/plotpdf savefigure

grid = getgrid(ebsd,'checkPhase',varargin{:});
cs = get(grid,'CS');
ss = get(grid,'SS');

%% subsample to reduce size
if sum(GridLength(grid)) > 2000 || check_option(varargin,'points')
  points = get_option(varargin,'points',2000);
  disp(['plot ', int2str(points) ,' random orientations out of ', ...
    int2str(sum(GridLength(grid))),' given orientations']);
  grid = subsample(grid,points);
end

%% prepare new figure
if newMTEXplot('ensureTag','ebsd_scatter',...
    'ensureAppdata',{{'CS',ebsd(1).CS},{'SS',ebsd(1).SS}});
  
  % reference orientation for fundamental region
  if ~check_option(varargin,'center')
    varargin = {varargin{:},'center',mean(grid)};
  end
    
else
  
  varargin = {'center',getappdata(gca,'center'),varargin{:}};
  
end




%% plot
plot(grid,'scatter',varargin{:});

%% store appdata
setappdata(gcf,'CS',cs);
setappdata(gcf,'SS',ss);
setappdata(gca,'center',get_option(varargin,'center'));
set(gcf,'tag','ebsd_scatter');
