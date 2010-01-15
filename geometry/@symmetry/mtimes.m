function R = mtimes(a,b)
% symmetry * quaternion

if isa(a,'symmetry') 
  if strcmp(a.laue,'1')
    R = b;
    return
  end
  a = a.quat(:);
elseif isa(b,'symmetry')
  if strcmp(b.laue,'1')
    R = a;
    return
  end
  b = reshape(b.quat,1,[]);
end
R = a * b;
