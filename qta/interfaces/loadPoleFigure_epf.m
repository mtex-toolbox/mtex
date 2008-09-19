function pf = loadPoleFigure_epf(fname,varargin)
% load epf file 
%
%% Syntax
% pf = loadPoleFigure_epf(fname,<options>)
%
%% Input
%  fname - file name
%
%% Output
%  pf    - @PoleFigure
%
%% See also
% loadPoleFigure interfaces_index
% 

fid = efopen(fname);

try
  h = string2Miller(fname); 
  lines = textscan(fid,'%s','delimiter','\n','whitespace','');
  
  d = [];
  for i=3:length(lines{:})
    k = lines{:}{i};
    if ~isempty(k)
      for i=2:4:73
        d = [d, sscanf(k(i:i+3),'%d')];
      end
    else break
    end
  end
  r = S2Grid('regular','points',[72 19],'north');

  
  pf = PoleFigure(h, r, d, symmetry('cubic'), symmetry);
catch
  error('file not found or format EPF does not match file %s',fname);
end

fclose(fid);