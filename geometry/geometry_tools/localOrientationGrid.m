function ori = localOrientationGrid(CS,SS,maxAngle,varargin)
% define a equispaced grid localized to a center orientation
%
% Syntax
%
%   ori = localOrientationGrid(CS,SS,maxAngle,'center',center)
% 
% Input
%  CS       - @symmetry
%  SS       - @symmetry
%  maxAngle - radius of the ball of orientations
%  center   - @orientation
%
% Output
%
%  ori - @orientation
%

% get resolution
if check_option(varargin,'points')
  res = maxAngle/(get_option(varargin,'points')/4)^(1/3);
else
  res = get_option(varargin,'resolution',5*degree);
end

% construct an equispaced axes / angle grid
rotAngle = res/2:res:maxAngle;
qId = quaternion();
for i = 1:length(rotAngle)
  
  dres = acos(max((cos(res/2) - cos(rotAngle(i)/2)^2)/...
    (sin(rotAngle(i)/2)^2),-1));  
  axes = equispacedS2Grid('resolution',dres);
  
  qId = [qId,axis2quat(axes,rotAngle(i))]; %#ok<AGROW>
end

% shift the grid to center
center = get_option(varargin,'center',rotation.id);
ori = mtimes(qId,center,1);

% ensure we respect the fundamental region
if numSym(CS.properGroup) > 1 && numSym(SS.properGroup) > 1 && length(center)==1
  
  % in order to avoid centers that are exactly at the boundary of the
  % fundamental region we distort the center slightly
  sym_center = symmetrise(...
    times(center,axis2quat(vector3d(3,2,1),0.001*degree),0),'proper');
  
  % we have only to check for those sym_centers that are not to far away
  delta = angle(sym_center(1),sym_center,'noSymmetry');
  sym_center = sym_center(delta < 2*maxAngle);

  % take only those orientations that are closest to center
  [~,ind] = min(angle_outer(ori,sym_center,'noSymmetry'),[],2);
  ori = ori(ind == 1);

end

end
