function line(v,varargin)

scatter(reshape(v,[],1),varargin{:},'edgecolor',...
  get_option(varargin,{'color','linecolor'},'k'),'Marker','none');
