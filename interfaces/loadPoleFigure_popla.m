function pf = loadPoleFigure_popla(fname,varargin)
% import data fom Popla file
%
% Syntax
%   pf = loadPoleFigure_popla(fname)
%
% Input
%  fname    - filename
%
% Output
%  pf - vector of @PoleFigure
%
% See also
% ImportPoleFigureData loadPoleFigure


fid = efopen(fname);

ipf = 1;

try
  while ~feof(fid)
    
    try
      
      % read header
      % first line --> comments
      comment = fgetl(fid);
      % second line
      s = fgetl(fid);
      
      p = @(k) s(5*k+1:5*k+5);
      n = @(k) str2num(p(k));
      m = @(k) str2num(s(26+(k*2:k*2+1)));
      
      % Miller indice
      allH{ipf} = string2Miller(p(0));
      
      dtheta = n(1); assert(dtheta > 0 && dtheta < 90);
      mtheta = n(2); assert(mtheta > 0 && mtheta <= 180);
      drho = n(3); assert(drho > 0 && drho < 90);
      mrho = n(4); assert(mrho > 0 && mrho <= 360);
      shifttheta = m(0); assert(shifttheta == 1 || shifttheta == 0);
      shiftrho = m(1); assert(abs(shiftrho) == 1 || shiftrho == 0);
      iper = [m(2) m(3) m(4)]; assert(all(abs(iper)>0) && all(abs(iper)<4));
      scaling = n(7); assert(scaling>0);
      bg = n(8);
      
      % generate specimen directions
      theta = (dtheta*~shifttheta/2:dtheta:mtheta)*degree;
      rho = (drho*~shiftrho/2:drho:mrho-drho/(1+~shiftrho))*degree;
      allR{ipf} = regularS2Grid('theta',theta,'rho',rho,'antipodal');
      
      % read data
      % TODO there are some data files that have 18 and some that have 19
      % colums - make interface working for those!
      d = [];
      l = fgetl(fid);
      while ~isempty(l) && ischar(l) %length(d) < length(r)
        l = l(1+mod(numel(l),4):end);
        data = str2num(reshape(l,4,[])');
        d = [d; data(1:18) ./ scaling];        
        l = fgetl(fid);
      end
      
      % restrict data to specified domain
      allI{ipf} = double(reshape(d(1:length(allR{ipf})),size(allR{ipf})));
            
      ipf = ipf+1;
    catch %#ok<CTCH>
      if ~exist('pf','var')
        interfaceError(fname,fid);
      end
    end
  end
  
  % generate Polefigure
  pf = PoleFigure(allH,allR,allI,varargin{:});
catch
  interfaceError(fname,fid);
end

fclose(fid);
