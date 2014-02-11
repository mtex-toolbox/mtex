function varargout = sphericalRegion(S2G,varargin)
    
% get fundamental region
[varargout{1:nargout}] = getFundamentalRegionPF(S2G.CS,varargin{:});
    
end
