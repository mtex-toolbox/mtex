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

o = get(ebsd,'orientations','checkPhase',varargin{:});
cs = get(o,'CS');
ss = get(o,'SS');

%% subsample to reduce size
if numel(o) > 2000 || check_option(varargin,'points')
  points = get_option(varargin,'points',2000);
  disp(['plot ', int2str(points) ,' random orientations out of ', ...
    int2str(numel(o)),' given orientations']);
  o = o(discretesample(ones(1,numel(o)),fix(points)));
end

%% prepare new figure
if newMTEXplot('ensureTag','ebsd_scatter',...
    'ensureAppdata',{{'CS',cs},{'SS',ss}});
  
  % reference orientation for fundamental region
  if ~check_option(varargin,'center')
    varargin = [varargin,{'center',mean(o)}];
  end
    
else
  
  varargin = {'center',getappdata(gca,'center'),varargin{:}};
  
end




%% plot
plot(o,'scatter',varargin{:});

%% store appdata
setappdata(gcf,'CS',cs);
setappdata(gcf,'SS',ss);
setappdata(gca,'center',get_option(varargin,'center'));
set(gcf,'tag','ebsd_scatter');
