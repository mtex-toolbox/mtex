function [rhoMin,rhoMax] = rhoRange(sR)
% compute range of the polar angle of a spherical region

if isempty(sR.N) || ...
    (length(sR.N) == 1 && sR.N.z~=0 && sR.alpha == 0)
        
  rhoMin = 0;
  rhoMax = 2*pi;
  return
end

% antipodal should not increase spherical region
sR.antipodal = false;

% discretisation
omega = linspace(0,2*pi,361);

% start with equator
v = vector3d('theta',pi/2,'rho',omega);
rho = v.rho(sR.checkInside(v));

% cylce through boundary
for i = 1:length(sR.N)
  
  b = vector3d('theta',acos(sR.alpha(i)),'rho',omega);
  
  rot = rotation.map(zvector,sR.N(i));
  
  b = rot * b;
  
  % remove points close to north and south
  % as we can not determine rho very well
  b(abs(b.theta-pi/2)>pi/2-1e-4)= [];
  
  rho = [rho,b.rho(sR.checkInside(b))]; %#ok<AGROW>
    
end

rho = sort(mod(rho,2*pi));

% find all holes in the rho list
ind = find(abs(diff(rho))>20*degree);

% maybe there is also a hole in zero
if rho(end)-rho(1)<340*degree, ind = [ind, length(rho)]; end


if isempty(ind)
  
  if isempty(rho)
    rhoMin = 0;
    rhoMax = 2*pi;
  else    
    rhoMin = min(rho);
    rhoMax = max(rho);
  end
  
else
  rhoMin = rho(mod(ind([end,1:end-1]),length(rho))+1);
  rhoMax = rho(ind);
  
  ind = rhoMin > rhoMax;
  rhoMin(ind) = rhoMin(ind) - 2*pi;
  
end
