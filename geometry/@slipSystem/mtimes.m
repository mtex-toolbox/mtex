function sS = mtimes(rot,sS)
% scale or rotate list of slipSystem

if isa(rot,'rotation')
  
  sS = rotate_outer(rot,sS);
  
elseif isnumeric(rot)
  
  sS.b = rot * sS.b;
  
else
  
  sS = mtimes(sS,rot);
  
end
