function pf = loadPoleFigure_ibm(fname,varargin)
% import data fom ibm file
%
%% Syntax
% pf = loadPoleFigure_ibm(fname,<options>)
%
%% Input
%  fname    - filename
%
%% Output
%  pf - vector of @PoleFigure
%
%% See also
% ImportPoleFigureData loadPoleFigure

assertExtension(fname,'.ibm');

fid = efopen(fname);

ipf = 1;

try
  
  comment = strtrim(fgetl(fid));
  % ignore line
  fgetl(fid);
  fgetl(fid);
  
  while ~feof(fid)
    
    s = fgetl(fid);
    p = textscan(s,'%s %s %s %s');
    h = string2Miller(char(p{1}));
    fgetl(fid);
    
    d = textscan(fid,'%d',72*19);
    d = reshape(d{1},[72 19]);
    
    r = S2Grid('regular','points',size(d));
    
    % generate Polefigure
    pf(ipf) = PoleFigure(h,r,double(d),'comment',comment,varargin{:}); %#ok<AGROW>
    %comment = [];
    ipf = ipf+1;
    fgetl(fid);
    fgetl(fid);
    fgetl(fid);
    
  end
  
catch %#ok<CTCH>
  if ~exist('pf','var')
    interfaceError(fname,fid);
  end
end

fclose(fid);
