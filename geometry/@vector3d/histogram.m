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
  
  % oddly, matlab returns bins in the range -pi:pi and the data 
  % within 0:2*pi with some data < 0
  edges = h.BinEdges;
  edges(edges<0)=pi-edges(edges<0);
  data=mod(h.Data,2*pi);

  [~,~,binId] = histcounts(data,sort(edges));
  h.BinCounts = accumarray(binId,weights,[length(h.BinEdges)-1 1],@nansum).' ./ sum(weights);
end
    
  
% set plotting convention such that the plot coinices with a map
x = getMTEXpref('xAxisDirection');
switch x
  case 'east'
    h.Parent.ThetaZeroLocation='right';
  case 'north'
    h.Parent.ThetaZeroLocation='top';
  case 'west'
    h.Parent.ThetaZeroLocation='left';
  case 'south'
    h.Parent.ThetaZeroLocation='bottom';
end

z  = getMTEXpref('zAxisDirection');
switch z
  case 'intoPlane'
    h.Parent.ThetaDir='clockwise';
  case 'outOfPlane'
    h.Parent.ThetaDir='counterclockwise';
end


if nargout == 0, clear h; end

end
