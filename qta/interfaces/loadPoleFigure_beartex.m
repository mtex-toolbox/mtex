function pf = loadPoleFigure_beartex(fname,varargin)
% import data fom BeaTex file
%
%% Syntax
% pf = loadPoleFigure_beartex(fname,<options>)
%
%% Input
%  fname    - filename
%
%% Output
%  pf - vector of @PoleFigure
%
%% See also
% interfacesPoleFigure_index beartex_interface loadPoleFigure

fid = efopen(fname);

ipf = 1;
r = S2Grid('regular','points',[72, 19],'antipodal'); 
spacegroup =  {'C1','C2','D2','C4','D4','T','O','C3','D3','C6','D6'};

try
  while ~feof(fid)

   try % next polefigure
     c = textscan(fid,'%s',7,'delimiter','\n','whitespace','');
     comment = deblank(c{1}{1}(1:50));
   catch
     if ~exist('pf','var')
      error('format BearTex does not match file %s',fname);
     else
       break
     end
   end

   crystal = cell2mat(textscan(c{1}{6},'%n'))';
   cs = symmetry(spacegroup{crystal(7)}, crystal(4:6)*degree,crystal(1:3));
   ss = symmetry(spacegroup{crystal(8)});

   gridinfo = c{1}{7};
   hkl = cell2mat(textscan(gridinfo,'%n',3));
   h = Miller(hkl(1),hkl(2),hkl(3),cs);


   k = 11:5:40;
   info = zeros(size(k));
   for l = 1:numel(k), info(l) = str2num(gridinfo( k(l):k(l)+4)); end
  % 
  %  theta = 0:info(3):90-info(3);
  %  rho = 0:info(6):360-info(6);

   data = zeros(18,72);
   for k = 1:76
    l = fgetl(fid);
    data(:,k) = str2num( reshape(l(2:end),4,[]).' );
   end

   fgetl(fid);

   pf(ipf) = PoleFigure(h,r,data,cs,ss,'comment',comment,varargin{:});

   mintheta = str2num(gridinfo(12:15));
   maxtheta = str2num(gridinfo(16:20));

   pf(ipf) = delete(pf(ipf), get(pf(ipf),'theta')  < info(1)*degree-eps | ...
     get(pf(ipf),'theta')  > info(2)*degree+eps);

   ipf = ipf+1;
  end
catch
  if ~exist('pf','var')
    error('format BearTex does not match file %s',fname);
  end
end