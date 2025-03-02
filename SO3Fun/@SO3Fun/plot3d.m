function plot3d(odf,varargin)
% plots odf

if odf.antipodal, ap = {'antipodal'}; else, ap = {}; end

[oP, isNew] = newOrientationPlot(odf.CS,odf.SS,ap{:},'project2FundamentalRegion',...
  varargin{:});

S3G = oP.makeGrid('resolution',5*degree,varargin{:});

oP.contour3s(reshape(odf.eval(S3G),size(S3G)),varargin{:});

if isNew, drawNow(gcm,varargin{:}); end

end
