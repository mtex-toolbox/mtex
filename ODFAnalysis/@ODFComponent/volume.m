function [v,S3G] = volume(component,center,radius,S3G,varargin)

% get resolution
res = get_option(varargin,'RESOLUTION',min(1.25*degree,radius/30),'double');

% discretisation
if nargin < 4 || isempty(S3G)
  S3G = equispacedSO3Grid(component.CS,component.SS,...
    'maxAngle',radius,'center',center,'resolution',res,varargin{:});
end

% estimate volume portion of odf space
reference = 9897129 * 96 / numProper(component.CS) / numProper(component.SS);
f = min(1,length(S3G) * (res / 0.25 / degree)^3 / reference);
  
% eval odf
if f == 0
  v = 0;
else
  v = mean(eval(component,S3G)) * f;
  v = min(v,1);
end
