function pf = loadPoleFigure_pwd(fname,varargin)
% load D5000 powder data file
%
%% Syntax
% pf = loadPoleFigure_pwd(fname,<options>)
%
%% Input
%  fname - file name
%
%% Output
%  pf    - @PoleFigure
%
%% See also
% loadPoleFigure ImportPoleFigureData

assertExtension(fname,'.pwd');

% open the file
fid = fopen(fname,'r');

try
  p = 0;
  while ~feof(fid)
    line = fgetl(fid);
    
    % lines starting with indicates a new pole figure
    if strfind(line,'R')
      
      p = p+1; k=1;
      h(p) = string2Miller(line(2:end));
      
      % if not a command line - it is a data line
    elseif isempty(regexp(line,'[*#]'))
      
      % get theta, defocussing and defocussing background
      dat = sscanf(line,'%f');
      if ~isempty(dat)
        theta(p,k) = dat(1); %#ok<*AGROW>
        def(p,k)  = dat(2);
        defbg(p,k) = dat(3);
        k = k+1;
      end
    end
  end
  
  fclose(fid);
  
catch
  interfaceError(fname,fid);
end

% compute defocussing
theta = theta*degree;
d = def-defbg;

% store defocussing in a pole figure variable
for p=1:numel(h)
  th = theta(p,:);
  r = S2Grid(sph2vec(th,zeros(size(th))));
  pf(p) = PoleFigure(h(p),r,d(p,:),varargin{:});
end
