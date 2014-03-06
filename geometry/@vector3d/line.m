function varargout = line(v, varargin )

% where to plot
[ax,v,varargin] = splitNorthSouth(v,varargin{:},'line');
if isempty(ax)
  varargout{1} = v;
  return;
end

[h p] = scatter(ax,reshape(v,[],1),varargin{:});

p = optiondraw(p,'edgecolor',get_option(varargin,{'color','linecolor'},'k'),...
  'Marker','none');

if nargout>0
  varargout{1} = h;
  varargout{2} = p;
end
