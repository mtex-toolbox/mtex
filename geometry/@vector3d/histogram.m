function h = histogram(v,varargin)

weights = get_option(varargin,'weights');
varargin = delete_option(varargin,'weights',1);

rho = v.rho(:);
antipodalflag = v.antipodal || check_option(varargin,'antipodal');

if v.antipodal || check_option(varargin,'antipodal')
  rho = mod(rho,pi); % prevent funny behavior of h.Binedeges/data
  rho = [rho; pi+rho]; 
  weights = [weights(:);weights(:)];
  varargin = delete_option(varargin,'antipodal');
end

h = polarhistogram(rho,varargin{:});

if ~isempty(weights)
  
  edges = h.BinEdges;
  %edges(edges<0)=pi-edges(edges<0);
  data=mod(h.Data,2*pi);
  
  if ~antipodalflag
    data(data>pi) = data(data>pi)-2*pi;
  end

  [~,~,binId] = histcounts(data,sort(edges));
  binId(binId==0)=length(edges)-1;
  weights(isnan(weights)) = 0;
  h.BinCounts = accumarray(binId,weights,[length(h.BinEdges)-1 1]).' ./ sum(weights);
end
    
  
% set plotting convention such that the plot coincides with a map
how2plot = getClass(varargin,'plottingConvention',getMTEXpref('xyzPlotting'));
how2plot.setView(h.Parent);

if nargout == 0, clear h; end

end
