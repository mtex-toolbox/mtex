function pf = loadPoleFigure_saclay(fname,varargin)
% load dubna cnv file 
%
%% Syntax
% pf = loadPoleFigure_saclay(fname,<options>)
%
%% Input
%  fname - file name
%
%% Output
%  pf    - @PoleFigure
%
%% See also
% loadPoleFigure ImportPoleFigureData

try
  d = load(fname);
catch
  interfaceError(fname);
end

if ~isa(d,'double') || size(d,1)~=73 ||...
    size(d,2)<5
  interfaceError(fname);
end

d = d(1:end-1,:);

h = string2Miller(fname(2:end));

if check_option(varargin,'maxTheta')
  maxTheta = get_option(varargin,'maxTheta');
else
  thetaStep = get_option(varargin,'thetaStep',5*degree);
  maxTheta = thetaStep * (size(d,2)-1);
end
  
r = S2Grid('regular','points',size(d),'antipodal','maxTheta',maxTheta);

  
pf = PoleFigure(h,r,d,symmetry('cubic'),symmetry,varargin{:});
