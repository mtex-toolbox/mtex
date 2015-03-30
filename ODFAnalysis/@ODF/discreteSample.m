function ori = discreteSample(odf,npoints,varargin)
% draw a random sample
%
% TODO: this might also call ODFComponent/discreteSample

res = get_option(varargin,'resolution',5*degree);

% some local grid
% TODO: maybe crystal and specimen symmetry is not needed here
S3G_local = localOrientationGrid(odf.CS,odf.SS,res,'resolution',res/5);

% take local random samples
q2 = discreteSample(quaternion(S3G_local),npoints);

% the global grid
if check_option(varargin,'precompute_d')
  S3G_global = get_option(varargin,'S3G');
  d = get_option(varargin,'precompute_d',[]);
else
  S3G_global = equispacedSO3Grid(odf.CS,odf.SS,'resolution',res);
  d = eval(odf,S3G_global); %#ok<EVLC>
end

% take global random samples
d(d<0) = 0;   
q1 = quaternion(S3G_global,discretesample(d,npoints));

% combine local and global
ori = orientation(q1(:) .* q2(:),odf.CS,odf.SS);
