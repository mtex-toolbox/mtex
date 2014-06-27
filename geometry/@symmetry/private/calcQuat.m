function rot = calcQuat(Laue,axis,inv,varargin)
% calculate quaternions for Laue groups

ll0axis = vector3d(1,1,0);
%Tl0axis = axis(1)+axis(2);
lllaxis = vector3d(1,1,1);

if check_option(varargin,{'2||a','m||a'})
  twoFoldAxis = axis(1);
elseif check_option(varargin,{'2||c','m||c'})
  twoFoldAxis = axis(3);
else
  twoFoldAxis = axis(2);
end

% compute rotations
switch Laue
  case '-1'
    rot = {rotation('Euler',0,0,0)};
  case '2/m'
  
    % determine rotation axis
    % this should be orthogonal to the other two axes
    orth = sum(abs(dot_outer(axis,axis)));    
    if all(round(orth)==1)
      rot = {Axis(twoFoldAxis,2)};    
    else
      rot = {Axis(axis(round(orth)==1),2)};
    end
  case 'mmm'
    rot = {Axis(axis(1),2),Axis(axis(3),2)};
  case '-3'
    rot = {Axis(axis(3),3)};
  case '-3m'
    rot = {Axis(twoFoldAxis,2),Axis(axis(3),3)};
  case '4/m'
    rot = {Axis(axis(3),4)};
  case '4/mmm' 
    rot = {Axis(axis(1),2),Axis(axis(3),4)};
  case '6/m'
    rot = {Axis(axis(3),6)};
  case '6/mmm'
    rot = {Axis(axis(2),2),Axis(axis(3),6)};
  case 'm-3'
    rot = {Axis(lllaxis,3),Axis(axis(1),2),Axis(axis(3),2)};
  case 'm-3m'
    rot = {Axis(lllaxis,3),Axis(ll0axis,2),Axis(axis(3),4)};
end

% apply inversion
if size(inv,1) == 2
  rot = [rot,{[rotation(idquaternion),-rotation(idquaternion)]}];
else
  rot = arrayfun(@(i) rot{i} .* inv(i).^(0:length(rot{i})-1) ,...
    1:length(rot),'uniformOutput',false);
  
end

rot = prod(rot{:});

