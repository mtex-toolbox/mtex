function [rhoMin,rhoMax] = rhoRange(sR)
% compute range of the polar angle of a spherical region

% antipodal should not increase spherical region
sR.antipodal = false;

% discretisation
omega = linspace(0,2*pi,361);

% start with equator
v = vector3d('theta',pi/2,'rho',omega);
rho = v(sR.checkInside(v)).rho;

% cylce through boundary
for i = 1:length(sR.N)
  
  b = vector3d('theta',acos(sR.alpha(i)),'rho',omega);
  
  rot = rotation('map',zvector,sR.N(i));
  
  b = rot * b;
  
  % remove points close to north and south
  % as we can not determine rho very well
  b(abs(b.theta-pi/2)>pi/2-1e-4)= [];
  
  rho = [rho,b(sR.checkInside(b)).rho]; %#ok<AGROW>
    
end

rho = sort(mod(rho,2*pi));

ind = find(abs(diff(rho))>20*degree);

if isempty(ind)
  
  if isempty(rho)
    rhoMin = 0;
    rhoMax = 2*pi;
  else    
    rhoMin = min(rho);
    rhoMax = max(rho);
  end
  
else
  rhoMin = rho(ind+1)-2*pi;
  rhoMax = rho(ind);
end

%   function [rhoMin,rhoMax] = rhoRange(sR)
%       
%       ind = angle(sR.N,zvector,'antipodal') > 1e-5;
%       N = unique(sR.N(ind));
%       
%       if isempty(sR.N)
%         rhoMin = 0;
%         rhoMax = 2*pi;
%       elseif length(N) == 1
%         
%         
%       else
%         
%         if sR.isUpper && sR.isLower
%           v = sR.restrict2Lower.vertices;
%         else
%           v = sR.vertices;
%         end
%         
%         rhoMin = min(v.rho(~isnull(v.theta)));
%         rhoMax = max(v.rho(~isnull(v.theta)));
%                 
%       end
%       
%       %TODO: we may need to interchange rhoMin and rhoMax
%       
%     end
%     
%   
