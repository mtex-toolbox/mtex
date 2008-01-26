function ebsd = simulateEBSD(odf,points,varargin)
%
%% Input
%  odf    - @ODF
%  points - number of orientation to be simualted
%
%% Output
%  ebsd   - @EBSD
%
%% Options
%
%
%% See Also
%

cs = odf(1).CS;
ss = odf(1).SS;

res = get_option(varargin,'resolution',5*degree);
S3G_global = SO3Grid(res,cs,ss);
S3G_local = SO3Grid(res/5,cs,ss,'max_angle',res);

d = eval(odf,S3G_global);

r1 = randsample(GridLength(S3G_global),points,1,d);
r2 = randsample(GridLength(S3G_local),points,1);

q = quaternion(S3G_global,r1) .* quaternion(S3G_local,r2);

clear S3G_global; clear S3G_local;

comment = get_option(varargin,'comment',...
  ['EBSD data simulated from ',getcomment(odf)]);
  
ebsd = EBSD(SO3Grid(q,cs,ss),cs,ss,'comment',comment);
