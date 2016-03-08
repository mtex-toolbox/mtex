function ori = discreteSample(component,npoints,varargin)
% draw a random sample
%

% does not work with specimen symmetry other then triclinic
SS = component.SS;
component.SS = specimenSymmetry;
res = get_option(varargin,'resolution',5*degree);

% some local grid
S3G_local = localOrientationGrid(component.CS,component.SS,res,'resolution',res/5);

% take local random samples
q2 = discreteSample(quaternion(S3G_local),npoints);

% the global grid
S3G_global = equispacedSO3Grid(component.CS,component.SS,'resolution',res);
d = eval(component,S3G_global); %#ok<EVLC>

% take global random samples
d(d<0) = 0;   
q1 = quaternion(S3G_global,discretesample(d,npoints));

% combine local and global
ori = orientation(q1(:) .* q2(:),component.CS,SS);
