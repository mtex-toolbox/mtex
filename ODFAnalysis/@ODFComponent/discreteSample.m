function ori = discreteSample(component,npoints,varargin)
% draw a random sample
%

res = get_option(varargin,'resolution',5*degree);

% some local grid
S3G_local = localOrientationGrid(component.CS,component.SS,res,'resolution',res/5);

% the global grid
if check_option(varargin,'precompute_d')
  S3G_global = get_option(varargin,'S3G');
  d = get_option(varargin,'precompute_d',[]);
else
  S3G_global = equispacedSO3Grid(component.CS,component.SS,'resolution',res);
  d = eval(component,S3G_global); %#ok<EVLC>
end

d(d<0) = 0;
r1 = discretesample(d,npoints);

ori = orientation(reshape(quaternion(S3G_global(r1)),[],1) ...
  .* reshape(quaternion(discreteSample(S3G_local,npoints)),[],1),...
  component.CS,component.SS);
