function pf = loadPoleFigure_scintag(fname,varargin)
% import data fom scintag ascii file
%
% Syntax
%   pf = loadPoleFigure_scintag(fname)
%
% Input
%  fname    - filename
%
% Output
%  pf - vector of @PoleFigure
%
% See also
% ImportPoleFigureData loadPoleFigure


fid = fopen(fname,'r');
d = fread(fid);
fclose(fid);

try
  d(d==13) = [];
  d = char(d)';
  
  file_id = regexpi(d(1:200),'(?<=File ID:(.*?)\n)(.*?)\n','match');
  comment = file_id{1};
  h = string2Miller(comment);
  
  ranges = regexpsplit(d,'Range');
  axis = regexpsplit(ranges{1},'Axis');
  
  % extract the stepsize
  f = regexpi(axis(2:end),'(?<=Step Size  :)(.*?)\n','match');
  f = [f{:}]; f = [f{:}];
  f = str2num(f);
  step = f(find(f>0,1,'first'));
  
  % process the ranges
  for k=2:numel(ranges)
    range = ranges{k};
    
    po = sscanf(range,'%d')*step;
    
    low = sscanf(range(41:49),'%f');
    high = sscanf(range(87:95),'%f');
    
    bg = (low+high)/2;
    
    t = find(double(range(97:end))==10,1,'first');
    f = numel(sscanf(range(97:97+t),'%f'));
    
    data = sscanf(range(97:end),'%f');
    
    if f==3 % counts per second
      az = data(1:3:end);
      I(:,k-1) = data(2:3:end);
    else    % counts in time
      az = data(1:4:end);
      I(:,k-1) = data(2:4:end)*1000./data(3:4:end);
    end
    
    % background correction
    I(:,k-1) = I(:,k-1) - bg;
    
    % specimen direction
    r(:,k-1) = vector3d('theta',po*degree,'rho',az*degree);
    
  end
  
  pf = PoleFigure( h,r,I,varargin{:});
catch
  interfaceError(fname);
end
