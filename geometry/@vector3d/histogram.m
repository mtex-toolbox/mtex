function h = histogram(v,varargin)

weights = get_option(varargin,'weights');
varargin = delete_option(varargin,'weights',1);

rho = v.rho(:);
if v.antipodal || check_option(varargin,'antipodal')
  rho = [rho; pi+rho]; 
  weights = [weights(:);weights(:)];
  varargin = delete_option(varargin,'antipodal');
end

h = polarhistogram(rho,varargin{:});

if ~isempty(weights)
  
  [~,~,binId] = histcounts(h.Data,h.BinEdges);
  
  h.BinCounts = accumarray(binId,weights,[length(h.BinEdges)-1 1],@nansum).' ./ sum(weights);
end
  
if nargout == 0, clear h; end

end