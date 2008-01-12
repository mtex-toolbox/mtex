function q = calcQuat(Laue,axis)
% calculate quaternions for Laue groups

ll0axis = vector3d(1,1,0);
Tl0axis = axis(1)+axis(2);
lllaxis = vector3d(1,1,1);

switch Laue
case '-1'     
    q = quaternion(1,0,0,0);
case '2/m'    
    q = Axis(axis(2),2);
case 'mmm'    
    q = Axis(axis(3),2).'*Axis(axis(1),2);
case '-3'     
    q = Axis(axis(3),3);
case '-3m'   
    q = Axis(axis(3),3).'*Axis(axis(1),2);
case '4/m'    
    q = Axis(axis(3),4);
case '4/mmm' 
    q = reshape(Axis(axis(3),4).'*Axis(axis(1),2),[],1)*Axis(ll0axis,2);
case '6/m'    
    q = Axis(axis(3),6);
case '6/mmm'  
    q = reshape(Axis(axis(3),6).'*Axis(axis(1),2),[],1)*Axis(Tl0axis,2);
case 'm-3'    
    q = reshape(Axis(axis(1),2).'*Axis(axis(2),2),[],1)*Axis(lllaxis,3);
case 'm-3m'   
    q = reshape(Axis(axis(3),4).'*Axis(ll0axis,2),[],1)*Axis(lllaxis,3);
end
q = reshape(q,[],1);
