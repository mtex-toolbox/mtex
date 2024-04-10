function v = power(v,a)      
% overloads v.^a componentwise for the coordinates of vector3d

if isscalar(a)
  a=a.*[1,1,1];
end
if numel(a)==3
  v.x = (v.x).^a(1);
  v.y = (v.y).^a(2);
  v.z = (v.z).^a(3);
else
  error('Operator ''.^'' is not supported for operands of type ''vector3d''. Change the size of the exponent.')
end

end