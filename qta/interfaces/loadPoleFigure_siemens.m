function pf = loadPoleFigure_siemens(fname,varargin)
% load D5000 data file
%
% Syntax
%   pf = loadPoleFigure_D5000(fname,<options>)
%
% Input
%  fname - file name
%
% Output
%  pf    - @PoleFigure
%
% See also
% loadPoleFigure ImportPoleFigureData

fid = fopen(fname,'r');
d = [];
p = 0;

try
  while ~feof(fid)
    line = fgetl(fid);
    
    % new pole figure section
    if strfind(line,'*Pole figure:')
      p = p+1;
      h(p) = string2Miller(line(14:end));
      d{p} = [];
      theta{p} = [];
      
      % new theta angle
    elseif strfind(line,'*Khi')
      theta{p} = [theta{p} sscanf(line(7:end),'%f')]; %#ok<*AGROW>
      bg = [];
      
      % new background line
    elseif strfind(line,'background')
      bg = [bg sscanf(line(end-8:end),'%8f')];
      if numel(bg)>1
        bg = mean(bg);
      end
      
    elseif strfind(line,'*')
      %other information
      
      
    else % load intensities
      
      dd = cell2mat(textscan(line,'%n'));
      if ~isempty(bg), dd = dd - bg; end
      d{p} = [d{p},dd];
    end
    
  end
catch
  interfaceError(fname,fid);
end
fclose(fid);

% generate pole figure variable
for p=1:length(h)
  
  n = numel(d{p})/numel(theta{p});
  r = regularS2Grid('theta',theta{p}*degree,'rho',linspace(0,2*pi*(n-1/n),n));
  pf(p) = PoleFigure(h(p),r,d{p},varargin{:});
  
end
