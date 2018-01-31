function doZeroRange(solver,varargin)

zrm = getClass(varargin,'zeroRangeMethod');

if isempty(zrm), zrm = zeroRangeMethod(solver.pf,varargin{:}); end
  
isZero = zrm.checkZeroRange(solver.S3G);

solver.S3G = subGrid(solver.S3G,~isZero);

end