function pf = loadPoleFigure_xrd(fname,varargin)
% import data fom aachen ptx file
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
% interfaces_index aachen_interface loadPoleFigure

fid = efopen(fname);

d = textscan(fid,'%n %n %n','CommentStyle','*');

rho = linspace(0,360,73) * degree;
theta = linspace(90,0,19) * degree;

r = S2Grid('regular','theta',theta,'rho',rho);
h = string2Miller(fname);

cs = symmetry('cubic');
ss = symmetry('-1');

pf = PoleFigure(h,r,d{2},cs,ss);

fclose(fid);
