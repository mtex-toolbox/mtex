function ebsd = simulateEBSD(odf,points,varargin)
% simulate EBSD data from ODF
%
%% Syntax
%  ebsd = simulateEBSD(odf,points)
%
%% Input
%  odf    - @ODF
%  points - number of orientation to be simualted
%
%% Output
%  ebsd   - @EBSD
%
%
%% See Also
% ODF_simulatePoleFigure

cs = odf(1).CS;
ss = odf(1).SS;

argin_check(points,'double');

res = get_option(varargin,'resolution',5*degree);
S3G_global = SO3Grid(res,cs,ss);
S3G_local = SO3Grid(res/5,cs,ss,'max_angle',res);

d = eval(odf,S3G_global); %#ok<EVLC>

r1 = discretesample(d,points);
r2 = discretesample(numel(S3G_local),points,1);

q = orientation(quaternion(S3G_global(r1)).*quaternion(S3G_local(r2)),cs,ss);
%q = orientation(quaternion(S3G_global(r1)),cs,ss);

clear S3G_global; clear S3G_local;

comment = get_option(varargin,'comment',...
  ['EBSD data simulated from ',getcomment(odf)]);
  
ebsd = EBSD(orientation(q,cs,ss),cs,ss,'comment',comment);
