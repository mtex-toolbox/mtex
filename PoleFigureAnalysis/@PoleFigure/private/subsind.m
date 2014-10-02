function ind = subsind(pf,varargin)
% subindexing of PoleFigure data
%

while iscell(varargin{1}), varargin = [varargin{:}];end

% pf('111') or pf({'100','110'})
if iscellstr(varargin)
    
  h = cellfun(@(x) string2Miller(x,pf.CS),varargin,'uniformOutput',false);
    
elseif isa(varargin{1},'Miller') % pf(Miller(1,0,0,cs))
  
  h = cellfun(@(x) pf.CS.ensureCS(x),varargin);  
  
else % pf({1,2,3})
  
  ind = [varargin{:}];
  return
  
end

ind = [];

%
for i = 1:length(h)
  for j = 1:length(pf.allH)
    if any(isnull(angle_outer(h{i},pf.allH{j})))
      ind = [ind,j]; %#ok<AGROW>
    end
  end
end
