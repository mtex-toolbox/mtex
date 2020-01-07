function sVF = plus(sVF1, sVF2)
%
% Syntax
%   sVF = sVF1+sVF2
%   sVF = a+sVF1
%   sVF = sVF1+a
%

if isa(sVF1, 'vector3d')
  sVF = sVF2;
  sVF.x = sVF.x+sVF1.x;
  sVF.y = sVF.y+sVF1.y;
  sVF.z = sVF.z+sVF1.z;
  
elseif isa(sVF2, 'vector3d')
  sVF = sVF1;
  sVF.x = sVF.x+sVF2.x;
  sVF.y = sVF.y+sVF2.y;
  sVF.z = sVF.z+sVF2.z;

else
  sVF = sVF1;
  sVF.sF = sVF1.sF+sVF2.sF;

end

end
