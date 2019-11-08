function pf = loadPoleFigure_ibm(fname,varargin)
% import data fom ibm file
%
% Syntax
%   pf = loadPoleFigure_ibm(fname)
%
% Input
%  fname    - filename
%
% Output
%  pf - vector of @PoleFigure
%
% See also
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
    
    s = strtrim(fgetl(fid));
    while (isempty(s) || ~ischar(s))  && ~feof(fid)
      s = strtrim(fgetl(fid));
    end
    
    if ~ischar(s) || isempty(s), break;end
    p = textscan(s,'%s %s %s %s');
    h{ipf} = string2Miller(char(p{1}));
    fgetl(fid);
    
    tmp = textscan(fid,'%d',72*19);
    d{ipf} = double(reshape(tmp{1},[72 19]));
    
    r{ipf} = regularS2Grid('points',size(d{ipf}));
        
    %comment = [];
    ipf = ipf+1;
    fgetl(fid);
    fgetl(fid);
    fgetl(fid);
    
  end

  % generate Polefigure
  pf = PoleFigure(h,r,d,'comment',comment,varargin{:});
  
catch %#ok<CTCH>
  if ~exist('pf','var')
    interfaceError(fname,fid);
  end
end

fclose(fid);
