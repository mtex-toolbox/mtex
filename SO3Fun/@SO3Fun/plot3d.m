function plot3d(odf,varargin)
% plots odf

if ~odf.isReal
  warning(['Imaginary part of complex valued SO3Fun''s is ignored. ' ...
    'In the following only the real part is plotted.'])
  odf.isReal=1;
end

if odf.antipodal, ap = {'antipodal'}; else, ap = {}; end

[oP, isNew] = newOrientationPlot(odf.CS,odf.SS,ap{:},'project2FundamentalRegion',...
  varargin{:});

S3G = oP.makeGrid('resolution',5*degree,varargin{:});

oP.contour3s(reshape(odf.eval(S3G),size(S3G)),varargin{:});

if isNew, drawNow(gcm,varargin{:}); end

end
