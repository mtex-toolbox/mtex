function S2G = quiverGrid(T,varargin)

if iseven(T.rank), varargin = [varargin,'antipodal']; end 
sR = fundamentalSector(T.CS,varargin{:});
S2G = equispacedS2Grid('resolution',10*degree,'no_center','antipodal',varargin{:});
S2G = S2G(sR.checkInside(S2G));
