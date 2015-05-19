function pf = loadPoleFigure_beartex(fname,varargin)
% import data fom BeaTex file
%
% Syntax
%   pf = loadPoleFigure_beartex(fname)
%
% Input
%  fname - filename
%
% Output
%  pf - @PoleFigure
%
% See also
% ImportPoleFigureData loadPoleFigure

pf = PoleFigure;
fid = efopen(fname);

ipf = 1;
r = regularS2Grid('points',[72, 19],'antipodal');
spacegroup =  {'C1','C2','D2','C4','D4','T','O','C3','D3','C6','D6'};

try
  while ~feof(fid)
    
    try % next polefigure
      for k=1:7, c{k} = fgetl(fid); end
      % c = textscan(fid,'%s',7,'delimiter','\n','whitespace','');
      comment = deblank(c{1}(1:50));
    catch
      if ~exist('data','var')
        error('format BearTex does not match file %s',fname);
      else
        break
      end
    end
    
    if ~exist('crystal','var')
      crystal = sscanf(c{6},'%f');
      cs = crystalSymmetry(spacegroup{crystal(7)}, crystal(1:3), crystal(4:6)*degree);
      ss = specimenSymmetry(spacegroup{crystal(8)});
    end
    
    hkl = sscanf(c{7},'%f',3);
    h{ipf} = Miller(hkl(1),hkl(2),hkl(3),cs);
    
       
    info = str2num(reshape(c{7}(11:40),5,[])');
    
    %  theta = 0:info(3):90-info(3);
    %  rho = 0:info(6):360-info(6);
    
    data{ipf} = zeros(18,72);
    for k = 1:76
      l = fgetl(fid);
      data{ipf}(:,k) = str2num( reshape(l(2:end),4,[]).' );
    end
  
    % restrict to the mesured region
    ind = r.theta < info(1)*degree-eps | r.theta > info(2)*degree+eps;
    allR{ipf} = r(~ind);
    data{ipf}(ind) = [];
    
    fgetl(fid);
            
    % mintheta = info(1);  maxtheta = info(2);            
    ipf = ipf+1;
  end
  
  pf = PoleFigure(h,allR,data,cs,ss,'comment',comment,varargin{:});

  fclose(fid);
  
catch
  if isempty(pf), interfaceError(fname,fid); end
end
