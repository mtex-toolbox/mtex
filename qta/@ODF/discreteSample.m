function ori = discreteSample(odf,npoints,varargin)
% draw a random sample
%

res = get_option(varargin,'resolution',5*degree);

% some local grid
S3G_local = localOrientationGrid(odf.CS,odf.SS,res,'resolution',res/5);

% the global grid
if check_option(varargin,'precompute_d')
  S3G_global = get_option(varargin,'S3G');
  d = get_option(varargin,'precompute_d',[]);
else
  S3G_global = equispacedSO3Grid(odf.CS,odf.SS,'resolution',res);
  d = eval(odf,S3G_global); %#ok<EVLC>
end

d(d<0) = 0;
    
r1 = discretesample(d,npoints);
r2 = discretesample(length(S3G_local),npoints,'XX');

ori = orientation(quaternion(S3G_global,r1) .* quaternion(S3G_local,r2),odf.CS,odf.SS);
