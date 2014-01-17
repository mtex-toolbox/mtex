function scatter(o,varargin)
% plots ebsd data as scatter plot
%
% Syntax
%   scatter(ebsd,<options>)
%
% Input
%  ebsd - @EBSD
%
% Options
%  axisAngle - axis angle projection
%  Rodrigues - rodrigues parameterization
%  points    - number of orientations to be plotted
%  center    - orientation center
%
% See also
% EBSD/plotpdf savefigure

% subsample to reduce size
if length(o) > 2000 || check_option(varargin,'points')
  points = fix(get_option(varargin,'points',2000));
  disp(['plot ', int2str(points) ,' random orientations out of ', ...
    int2str(length(o)),' given orientations']);
  o = subsref(o,discretesample(ones(1,length(o)),fix(points)));
end

% prepare new figure
if newMTEXplot('ensureTag','ebsd_scatter',...
    'ensureAppdata',{{'CS',o.CS},{'SS',o.SS}});
  
  % reference orientation for fundamental region
  if ~check_option(varargin,'center')
    varargin = [varargin,{'center',mean(o)}];
  end
    
else
  
  varargin = {'center',getappdata(gca,'center'),varargin{:}};
  
end


% ------------- plot -------------------------

% center of the plot
center = get_option(varargin,'center',idquaternion);
varargin = delete_option(varargin,'center');
q = project2FundamentalRegion(o,center);

plot(quaternion(q),'scatter',varargin{:});


% store appdata
setappdata(gcf,'CS',o.CS);
setappdata(gcf,'SS',o.SS);
setappdata(gca,'center',center);
set(gcf,'Name',['Scatter plot of "',get_option(varargin,'FigureTitle',inputname(1)),'"']);
set(gcf,'tag','ebsd_scatter');
