function pf = loadPoleFigure_labotex(fname,varargin)
% load labotex pole figure data
%
% Input
% fname - file name
%
% Output
% pf    - @PoleFigure
%
% See also
% ImportPoleFigureData loadPoleFigure

% open the file
fid = efopen(fname);

% read header

try
  
  % first line --> comments
  comment = fgetl(fid);
  % skip next lines
  fgetl(fid);
  s = fgetl(fid);
  assert(strncmpi('Structure Code',s,14));
  
  % crystal symmetry
  s = fgetl(fid);
  c = sscanf(s,'%d%f%f%f%f%f%f');
  spacegroup =  {'C1','C2','D2','C4','D4','T','O','C3','D3','C6','D6'};
  cs = crystalSymmetry(spacegroup{c(1)},c(2:4),c(5:7)*degree);
  
  % number of pole figures
  s = fgetl(fid);
  npf = sscanf(s,'%d');
  
  % skip one line
  s = fgetl(fid);
  
  % hr information
  for n = 1:npf
    s = fgetl(fid);
    hr = sscanf(s,'%f%f%f%f%f%f%f%f%d%d%d%d%d');
    theta = (hr(2):hr(4):hr(3))*degree;
    rho = (hr(5):hr(7):hr(6))*degree;
    r{n} = regularS2Grid('theta',theta,'rho',rho,'antipodal'); %#ok<AGROW>
    h{n} = Miller(hr(9),hr(10),hr(11),cs); %#ok<AGROW>
  end
  
  for n = 1:npf
    
    % read data
    tmp = textscan(fid,'%f',length(r{n}));
    d{n} = reshape(double(tmp{1}),size(r{n}));

  end
  
  % construct pole figure object
  pf = PoleFigure(h,r,d,cs,'comment',comment,varargin{:});
  
catch %#ok<CTCH>
  interfaceError(fname,fid);
end

fclose(fid);
