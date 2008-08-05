function plot(v,varargin)
% plot three dimensional vector

if ~check_option(varargin,'scatter')  
  varargin = {varargin{:},'color','k'};
end

if length(v) > 20 || check_option(varargin,'data')    

  plot(S2Grid(v),varargin{:},'grid');
  
else
    
  if ~check_option(varargin,'data')
    % convert to cell
    s = cell(1,numel(v));
    for i = 1:numel(v), s{i} = subsref(v,i); end
    varargin = {'data',s,varargin{:}};    
  end
  
  plot(S2Grid(v),varargin{:},'grid');

end
