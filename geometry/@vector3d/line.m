function varargout = line(v, varargin )

% where to plot
[ax,v,varargin] = getAxHandle(v,varargin{:});


[h p] = scatter(ax,reshape(v,[],1),varargin{:});

p = optiondraw(p,'edgecolor',get_option(varargin,'color','k'),...
  'Marker','none');

if nargout>0
  varargout{1} = h;
  varargout{2} = p;
end
