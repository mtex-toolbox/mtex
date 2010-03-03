function pf = loadPoleFigure_out1(fname,varargin)
% import polfigure-data form Graz
%
%% Syntax
% pf = loadPoleFigure_out1(fname,<options>)
%
%% Input
%  fname  - filename
%
%% Output
%  pf - vector of @PoleFigure
%
%% See also
% interfacesPoleFigure_index loadPoleFigure

assert(strcmp(fname(end-2:end),'out'));

data = txt2mat(fname,'NumHeaderLines',15,'NumColumns',2,...
  'InfoLevel',0,'ReadMode','block','BadLineString',{'!@!'});

r = S2Grid('points',[72 18],'regular','maxtheta',85*degree);

gz = numel(r);
numpf = length(data)/gz;

h = [ Miller(1,0,0), Miller(1,1,0),  Miller(1,0,2),  Miller(2,0,0),...
      Miller(2,0,1), Miller(1,1,2),  Miller(2,1,1),  Miller(1,1,3)];
	if numpf > length(h), h(length(h)+1:numpf) = Miller(1,0,0); end

for k=0:numpf-1
  d = data((k*gz)+1:(k+1)*gz,2);
	pf(k+1) = PoleFigure(h(k+1),r,d,symmetry,symmetry); 
end
pf = delete(pf,getdata(pf)<0);
