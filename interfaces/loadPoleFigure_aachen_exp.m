function pf = loadPoleFigure_aachen_exp(fname,varargin)
% import data fom aachen_exp file
%
% Syntax
%   pf = loadPoleFigure_aachen_exp(fname)
%
% Input
%  fname  - filename
%
% Output
%  pf - vector of @PoleFigure
%
% See also
% ImportPoleFigureData loadPoleFigure

% open file
fid = efopen(fname);

try
  
  % skip first 3 lines
  textscan(fid,'%s',3,'delimiter','\n','whitespace','');
  
  % read grid data
  rd = textscan(fid,'%s %f %s %f %s %f %s %f %s %f\n',1);
  
  assert(strcmp(rd{1},'ALPHASTART') && strcmp(rd{3},'END') && ...
    strcmp(rd{5},'DELTA') && strcmp(rd{7},'BETASTART') && strcmp(rd{9},'DELTA'));
  
  rd = {rd{[2,4,6,8,10]}};
  assert_grid(rd{1},rd{3},rd{2},rd{4},rd{5},360-rd{4},'degree');
  
  theta = (rd{1}:rd{3}:rd{2})*degree;
  rho = (rd{4}:rd{5}:360-rd{5})*degree;
  r = regularS2Grid('theta',theta,'rho',rho,'antipodal');
  
  ip = 1;
  while ~feof(fid)
    
    % skip empty lines until mark HKL
    textscan(fid,'%*s',1,'delimiter','HKL','whitespace','');
    
    % read HKL
    hkl = fgetl(fid);
    hkl = regexp(hkl,'KL\s*([0-9_-]*).\s*THETA','tokens');
    h{ip} = string2Miller(char(hkl{1}));
    
    % read data
    for j = 1:length(theta)
      
      d{ip}(:,j) = fscanf(fid,'%e',length(rho));
      
      %skip theta mark
      textscan(fid,'-%*s');
      
    end
        
    ip = 1 + ip;
  end
  
catch
  
end

fclose(fid);

try
  pf = PoleFigure(h,r,d,crystalSymmetry('cubic'),specimenSymmetry);
catch
  interfaceError(fname,fid);
end
