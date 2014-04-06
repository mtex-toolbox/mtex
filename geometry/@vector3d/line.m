function varargout = line(v,varargin)

[varargout{1:nargout}] = scatter(reshape(v,[],1),varargin{:},'edgecolor',...
  get_option(varargin,{'color','linecolor'},'k'),'Marker','none');
