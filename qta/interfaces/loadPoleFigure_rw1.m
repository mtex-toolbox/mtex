function pf = loadPoleFigure_rw1(fname,varargin)
% import data from Philip's Xpert binary file format rw1
%
%% Syntax
% pf = loadPoleFigure_rw1(fname,<options>)
%
%% Input
%  fname  - filename
%
%% Output
%  pf - vector of @PoleFigure
%
%% See also
% ImportPoleFigureData loadPoleFigure


assertExtension(fname,'.rw1');

try
  
  fid = fopen(fname,'r');
  
  % descriptive text lines
  description = transpose(fread(fid,54,'*char'));
  
  % don't know what this lines mean
  data2 = transpose(fread(fid,352,'uint8'));
  % data2 = transpose(fread(fid,352/2,'uint16'));
  
  data = fread(fid,'int16=>double');
  fclose(fid);
  
  h = string2Miller(regexprep(description,'.*hkl:(\w*) (\w*) (\w*).*','$1$2$3'));
  
  data = reshape(data,72,[]);
  data = data(:,1:17);
  
  r = S2Grid('regular','theta',(0:5:80)*degree,...
    'rho',(2.5:5:360)*degree,'maxtheta',80*degree);
  
  % pf = PoleFigure(Miller(1,1,1),r,data,symmetry('cubic'),symmetry);
  pf = PoleFigure(h,r,data.^2/500,symmetry('cubic'),symmetry);
  
catch 
  interfaceError(fname,fid);
end


