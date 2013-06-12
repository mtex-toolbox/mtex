function q = calcQuat(Laue,axis,varargin)
% calculate quaternions for Laue groups

ll0axis = vector3d(1,1,0);
%Tl0axis = axis(1)+axis(2);
lllaxis = vector3d(1,1,1);
maxis = axis(1);


switch Laue
  case '-1'
    q = quaternion(1,0,0,0);
  case '2/m'
  
    % determine rotation axis
    % this should be orthogonal to the other two axes
    orth = sum(abs(dot_outer(axis,axis)));
    
    if all(round(orth)==1)
      q = Axis(axis(2),2);
    else
      q = Axis(axis(round(orth)==1),2);
    end
  case 'mmm'
    q = Axis(axis(1),2).'*Axis(axis(3),2);
  case '-3'
    q = Axis(axis(3),3);
  case '-3m'
    q = Axis(maxis,2).'*Axis(axis(3),3);
  case '4/m'
    q = Axis(axis(3),4);
  case '4/mmm' 
    q = Axis(axis(1),2).'*Axis(axis(3),4);
  case '6/m'
    q = Axis(axis(3),6);
  case '6/mmm'
    q = Axis(maxis,2).'*Axis(axis(3),6);
  case 'm-3'
    q = reshape((Axis(lllaxis,3).'*Axis(axis(1),2)).',[],1)*Axis(axis(3),2);
  case 'm-3m'
    q = reshape((Axis(lllaxis,3).'*Axis(ll0axis,2)).',[],1)*Axis(axis(3),4);
end
q = reshape(q.',[],1);
