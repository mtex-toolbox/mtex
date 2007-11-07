function [Ind,distance] = find(SO3G,q,epsilon)
% return indece and distance of all nodes within a eps neighborhood
%
% usage:  [Ind,dist] = find(SO3G,midpoint,radius)
%
%% Input
%  SO3G     - @SO3Grid
%  midpoint - @quaternion
%  radius   - double
%% Output
%  [indece, distances]


%if ~getflag(SO3G,'indexed')
  
distance = dist(SO3G.CS,SO3G.SS,q,SO3G.Grid);
Ind = find(distance<epsilon);
distance = distance(Ind);
return;
  
%end

Ind = [];
distance = [];

%  Ind = find(sdist(SO3G.CS,SO3G.SS,q,SO3G.Grid)<epsilon);
%  return

lz = cumsum([0,GridLength(SO3G.phi2)]);

% look for z-axis
Ind1 = find(SO3G.phi1Phi,q*zVector,epsilon);

Ind = [];
%  nz = Vector3d(SO3G.phi1Phi,Ind1);
%  axis = crossprod(nz,q*zVector);
%  naxis = norm(axis);
%  i = find(naxis==0); naxis(i)=1;
%  axis = 1./naxis .* axis;
%  axis(i)=xVector;
%  angle1 = pdist(q*zVector,nz);
%  
%  if m angle1 = min(angle1,pi-angle1);end
%  
%  % calculate maximal rotation of xaxis
%  omega = 2*acos(cos(epsilon/2)./cos(angle1/2));
%  
%  qaxis = q*axis;
%  naxis = SO3G.Grid(lz(Ind1)+1).'.*axis;
%  delta = pdist(naxis,qaxis);
    
for i=1:length(Ind1)
  Ind = [Ind,(lz(Ind1(i))+1):lz(Ind1(i)+1)];continue; %#ok<AGROW>
      
%  Ind = [Ind,lz(Ind1(i))+cunion([...
%  FindEnv(SO3G.phi2(Ind1(i)),...
%  double(SO3G.phi2(Ind1(i)),1)+delta(i),omega(i)),...
%  FindEnv(SO3G.phi2(Ind1(i)),...
%  double(SO3G.phi2(Ind1(i)),1)-delta(i),omega(i))])];

end
    
%disp(length(Ind));
% check orientations found so far
if numel(Ind)>0
  distance = dist(SO3G.CS,SO3G.SS,q,SO3G.Grid(Ind));
  t = find(distance<epsilon);
  Ind = Ind(t);
  distance = squeeze(distance(t));
end
