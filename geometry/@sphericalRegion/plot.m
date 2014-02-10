function varargout = plot(sR,varargin)
% plots a spherical region
%
% This function is called by all spherical plot methods to plot the outer
% boundary and adjust the axes limits properly.
%

[ax,v,varargin] = splitNorthSouth(gca,zvector,varargin{:});
%ax = get_option(varargin,'parent',gca);
   
% extract plot options
[projection,extend] = getProjection(ax,zvector,varargin{:});
   
omega = linspace(0,2*pi);
   
% store hold status
washold = getHoldState(ax);

hold on
for i=1:length(sR.N)
  
  rot = rotation('axis',sR.N(i),'angle',omega);
  bigCircle = rotate(orth(sR.N(i)),rot);
  v = sR.alpha(i) * sR.N(i) + sqrt(1-sR.alpha(i)^2) * bigCircle;
  
  % check data in region
  v = v(sR.checkInside(v));

  % project data
  [x,y] = project(v,projection,extend);
  
  h(i) = optiondraw(line(x,y),'color','k'); %#ok<AGROW>
  
        
end

% revert old hold status
hold(ax,washold);


% ------------- finalize the plot ----------------------------

% bounding box
% ------------
if ~isappdata(ax,'bounds')

  % get bounding box
  x = get(h,'xData'); x = [x{:}];
  y = get(h,'yData'); y = [y{:}];
  bounds = [min(x(:)),min(y(:)),max(x(:)),max(y(:))];

  % set bounds to axes
  delta = min(bounds(3:4) - bounds(1:2))*0.02;

  set(ax,'DataAspectRatio',[1 1 1],...
    'XLim',[bounds(1)-delta,bounds(3)+delta],...
    'YLim',[bounds(2)-delta,bounds(4)+delta]);

  % and store them
  setappdata(ax,'bounds',bounds);
  
  % store spherical region
  setappdata(ax,'sphericalRegion',sR);
  
end

% add annotations
%plotAnnotate(ax,varargin{:})

% plot a spherical grid
plotGrid(ax,projection,extend,varargin{:});

% give handles back
if nargout > 0, varargout{1} = ax; end

end
   
   

