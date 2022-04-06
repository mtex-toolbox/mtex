function ori = discreteSample(component,npoints,varargin)
% draw a random sample
%

% does not work with specimen symmetry other then triclinic
SS = component.SS;
component.SS = specimenSymmetry;
res = get_option(varargin,'resolution',5*degree);

% the global grid
S3G_global = equispacedSO3Grid(component.CS,component.SS,'resolution',res);
d = eval(component,S3G_global); %#ok<EVLC>

% take global random samples
d(d<0) = 0;   
q1 = quaternion(S3G_global,discretesample(d,npoints));

% some local distortions
q2 = quaternion.rand(npoints,'maxAngle',res);

% combine local and global
ori = orientation(q1(:) .* q2(:),component.CS,SS);
