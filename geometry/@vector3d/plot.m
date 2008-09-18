function plot(v,varargin)
% plot three dimensional vector

if ~check_option(varargin,'scatter')  
  varargin = {'MarkerFaceColor','k','MarkerEdgeColor','w','marker','s',...
    'LineWidth',1,'sizedata',80,varargin{:}};
end

if length(v) > 20 || check_option(varargin,'data')    

  plot(S2Grid(v),'grid',varargin{:});
  
else
    
  if ~check_option(varargin,'data')
    % convert to cell
    s = cell(1,numel(v));
    for i = 1:numel(v), s{i} = subsref(v,i); end
    varargin = {'data',s,varargin{:}};    
  end
  
  plot(S2Grid(v),'grid',varargin{:});

end
