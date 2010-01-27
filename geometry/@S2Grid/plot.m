function  varargout = plot(S2G,varargin)
% plot spherical data
%
% *S2G/plot* plots data on the sphere
%
%% Syntax
%  plot(S2G,<options>)
%
%% Input
%  S2G - @S2Grid
%
%% Options
%  DATA     - coloring of the points [double] or {string}
%  MarkerSize - diameter for single points plot [double]
%  RANGE    - minimum and maximum for color coding [min,max]
%  CONTOUR  - number of contour lines or list of contour lines
%  CONTOURF - number of contour lines or list of contour lines
%  ROTATE   - rotate plot about z-axis
%  FLIPUD   - FLIP plot upside down
%  FLIPLR   - FLIP plot left to rigth
%  PROJECTION - {EAREA}, EDIST, PLAIN
%
%% Flags
%  NORTH       - plot only points on the north hemisphere (default)
%  SOUTH       - plot only points on the southern hemisphere
%  antipodal      - include [[AxialDirectional.html,antipodal symmetry]]
%  DOTS        - single points (default) 
%  SMOOTH      - interpolated plot 
%  CONTOUR     - contour plot
%  CONTOURF    - filled contour plot
%  EAREA       - equal-area projection (default)
%  EDIST       - equal-distance projection  
%  PLAIN       - no projection    
%  GRAY        - colormap - gray 
%  LOGARITHMIC - log plot
%
%% See also
% savefigure plot_index Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 


% 3d plot is extern
if check_option(varargin,'3d'), plot3d(S2G,varargin{:});return; end

%% Prepare Axis

washold = ishold;
if ~check_option(varargin,'axis'), newplot;end
if isempty(get(gca,'children')) || all(strcmp(get(get(gca,'children'),'type'),'text'))
  rmallappdata(gcf);
end

if nargout > 0, varargout{1} = gca;end

if isappdata(gcf,'axes')
  varargin = [varargin,'annotate'];
else
  adjustToolbar('norotate');
end

set(gca,'Tag','S2Grid','Box','on','DataAspectRatio',[1 1 1],'XTick',[],'YTick',[],...
  'drawmode','fast','layer','top');

% color
if ~check_option(varargin,{'MarkerColor','MarkerFaceColor','CONTOUR','CONTOURF','SMOOTH','DATA'})
  [ls,c] = nextstyle(gca,true,true,~ishold);
  varargin = ['MarkerColor',c,varargin];
end


hold all

%%  GET OPTIONS 

% default plot options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

% S2Resolution
if numel(S2G)>100 || get(S2G,'resolution') < 10 *degree
  varargin = ['scatter_resolution',getResolution(S2G),varargin];
end

% extract data
data = get_option(varargin,'DATA',[]);
if numel(data) == numel(S2G)
  
  if isnumeric(data)
    
    data = reshape(data,size(S2G));
  
    % log plot?
    if check_option(varargin,'logarithmic')
      data = log10(data);
      data(imag(data) ~= 0 | isinf(data)) = nan;
    end
  
    varargin = [{'colorrange',[min(data(:)),max(data(:))]},varargin];
  end
elseif ndims(data) == 3 && all(size(data) == [size(S2G),3])
  
elseif check_option(varargin,'label')
  
  data = ensurecell(get_option(varargin,'label'),size(S2G));
  
else
  
  data = [];
  
end


% set correction flag for plotting pole figure data
if ~check_option(S2G,'plot') && ...
    check_option(varargin,{'CONTOUR','CONTOURF','SMOOTH','TEXTUREMAP','rgb'});
  if size(S2G,1) == 1 || size(S2G,2) == 1
    
    % interpolate
    mintheta = getMin(S2G.theta);
    maxtheta = getMax(S2G.theta);
    res = max(2.5*degree,get(S2G,'resolution'));
    newS2G = S2Grid('plot','resolution',res,...
      'mintheta',mintheta,'maxtheta',maxtheta,'restrict2minmax',varargin{:});
    
    [ind,d] = find(S2G,vector3d(newS2G));
    data = data(ind);
    data(d < cos(2*res)) = nan;
    S2G = newS2G;
    data = reshape(data,size(S2G));
    
  else
    varargin = [varargin,'correctContour'];
  end
end


% COLORMAP
if check_option(varargin,'GRAY'),colormap(flipud(colormap('gray'))/1.1);end


%% Prepare Coordinates
% calculate polar coordinates
[theta,rho] = polar(S2G);



%% Which Hemispheres to Plot

if isappdata(gcf,'hemisphere'), 
    
  hemisphere = getappdata(gcf,'hemisphere');
  
elseif check_option(varargin,{'antipodal','plain'})
  
  hemisphere = 'antipodal';
  
elseif check_option(varargin,{'north','south','antipodal'})
  
  hemisphere = extract_option(varargin,{'north','south','antipodal'});
   
elseif check_option(S2G,{'north','south','antipodal'})
  
  hemisphere = extract_option(S2G.options,{'north','south','antipodal'});

elseif max(theta(:)) > pi/2+0.001 
  
  hemisphere = {'north','south'};
  
else
  
  hemisphere = 'north';

end

setappdata(gcf,'hemisphere',hemisphere);
  
bounds = [0,0,0,0];


%% Northern Hemisphere

if any(strcmpi(hemisphere,'north')) || any(strcmpi(hemisphere,'antipodal'))
  
  if strcmp(hemisphere,'antipodal')
    south = theta > pi/2+0.001;
    rho(south) = rho(south) + pi;
    theta(south) = pi - theta(south);
    ind = true(size(theta));
  else
    ind = (theta <= pi/2+0.001) | isnan(theta);
  end
  
  if isa(S2G.theta,'S1Grid')
    maxtheta = min(pi/2,max(getMax(S2G.theta)));
  elseif isa(S2G.theta,'function_handle')
    maxtheta = S2G.theta;
  else
    maxtheta = pi/2;
  end
  
  bounds = plotHemiSphere(submatrix(theta,ind),submatrix(rho,ind),...
    submatrix(data,ind),0,'minrho',min(getMin(S2G.rho)),'maxrho',...
    max(getMax(S2G.rho)),'maxtheta',maxtheta,varargin{:});
end

%% Southern Hemisphere

if any(strcmpi(hemisphere,'south'))
  ind = theta >= pi/2-0.001;
  bounds = plotHemiSphere(pi-submatrix(theta,ind),submatrix(rho,ind),...
    submatrix(data,ind),bounds(3),'maxrho',max(getMax(S2G.rho)),varargin{:});
end


%% Finish

% Bounding Box
if ~check_option(varargin,{'annotate'})
  if check_option(varargin,'PLAIN')
    xlim([bounds(1),bounds(1)+bounds(3)]);
    ylim([bounds(2),bounds(2)+bounds(4)]);
  else
    xlim([bounds(1)-0.005,bounds(1)+bounds(3)+0.01]);
    ylim([bounds(2)-0.005,bounds(2)+bounds(4)+0.01]);
  end
end

% crop if neccary
if ~check_option(varargin,{'axis','annotate'})
  f = bounds(3) / bounds(4);
  set(gca,'units','normalized');
  set(gca,'position',[0.05/f 0.05 1-0.1/f 0.9]);
%  set(gca,'units','points');
  set(gcf,'units','points');
  fpos = get(gcf,'position');

  f = (f+0.1)/1.1;
  
  b = min(fpos(3) / f,fpos(4));
  set(gcf,'position',[fpos(1:2),b*f,b]);
  set(gcf,'Color',[1 1 1]);
  axis off;
end

% set hold back
if ~washold, hold off;end


%% Plot Hemisphere
function bounds = plotHemiSphere(theta,rho,data,offset,varargin)

% projection
[X,Y,bounds] = projectData(theta,rho,varargin{:});

% plot
box = bounds+[offset,0,bounds(1)+offset,bounds(2)];
if ~isempty(X), plotData(X+offset,Y,data,box,varargin{:});end

% bounding box
if ~check_option(varargin,'annotate')
  
  switch lower(getappdata(gcf,'projection'))
    case 'plain'
      plotPlainGrid(theta,rho,varargin{:});
    otherwise  
      polarGrid(offset,varargin{:});
  end
end

bounds(3) = bounds(3) + offset;
