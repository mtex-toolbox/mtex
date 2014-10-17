function S2G = plotS2Grid(T,varargin)
% define a plotting grid suitable for tensor plots
  
if iseven(T.rank)
  varargin = [varargin,'antipodal'];
end
  
sR = fundamentalSector(T.CS,varargin{:});
S2G = plotS2Grid(sR,varargin{:});
