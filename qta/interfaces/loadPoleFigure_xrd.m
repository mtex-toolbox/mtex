function pf = loadPoleFigure_xrd(fname,varargin)
% import data fom aachen xrd file
%
%% Syntax
% pf = loadPoleFigure_aachen_exp(fname,<options>)
%
%% Input
%  fname  - filename
%
%% Output
%  pf - vector of @PoleFigure
%
%% See also
% ImportPoleFigureData loadPoleFigure_aachen loadPoleFigure



%% read header

h = file2cell(fname,1000);

%search data for pole angles

rhoStart = readToken(h,'*MEAS_SCAN_START "');
rhoStep = readToken(h,'*MEAS_SCAN_STEP "');
rhoStop = readToken(h,'*MEAS_SCAN_STOP "');

rho = (rhoStart:rhoStep:rhoStop)*degree;

thetaStart = readToken(h,'*MEAS_3DE_ALPHA_START "');
thetaStep = readToken(h,'*MEAS_3DE_ALPHA_STEP "');
thetaStop = readToken(h,'*MEAS_3DE_ALPHA_STOP "');

theta = (thetaStart:thetaStep:thetaStop)*degree;

r = S2Grid('regular','theta',theta,'rho',rho);

h = string2Miller(fname);

%% read data

fid = efopen(fname);

d = textscan(fid,'%n %n %n','CommentStyle','*');

fclose(fid);

%% define Pole Figure

cs = symmetry('cubic');
ss = symmetry('-1');

pf = PoleFigure(h,r,d{2},cs,ss);


function value = readToken(str,token)

l = strmatch(token,str);
value = sscanf(str{l(1)},[token '%f']);
