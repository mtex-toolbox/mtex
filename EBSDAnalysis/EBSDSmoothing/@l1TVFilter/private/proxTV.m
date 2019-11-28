function [xOut,yOut] = proxTV(xIn,yIn,lambda,varargin)


t = lambda ./ angle(xIn,yIn,varargin{:});
%max(t,[],'all')
t = min(t,0.5);

% add some threshold
if 0
  t(mu>10*degree*sqrt(2)/(2*lambda))=0;
end

% xOut = geodesic(xIn,yIn,t,varargin{:});
% yOut = geodesic(xIn,yIn,1-t,varargin{:});
if 1
  l = log(yIn,xIn);
  xOut = exp(t .* l,xIn);
  yOut = exp((1-t) .* l,xIn);
else % this is not exact but faster  
  xOut = normalize((1-t).*xIn + t.*yIn);
  yOut = normalize(t.*xIn + (1-t).*yIn);
end
