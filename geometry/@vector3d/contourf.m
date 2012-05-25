function varargout = contourf( v, varargin )


% where to plot
ax = getAxHandle(v,varargin{:});

hold(ax,'all');

% number of contour lines
cl = get_option(varargin,'contours',10);


h1 = smooth(v,varargin{:},'contours',cl,'LineStyle','none','fill','on');
h2 = smooth(v,varargin{:},'contours',cl,'LineStyle','-','LineColor','k','fill','off');

hold off

% output
if nargout > 0
  varargout{1} = [h1,h2];
end
