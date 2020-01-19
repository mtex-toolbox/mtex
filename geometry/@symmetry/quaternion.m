function q = quaternion(sym)

rot = sym.rot;
if sym.isLaue  
  q = quaternion(rot(rot.i));
else
  q = quaternion(rot);
end

end