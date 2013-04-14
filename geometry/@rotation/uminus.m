function r = uminus(r)
% orientation times Miller and quaternion times orientation

if isempty(r.inversion)
  
  r.inversion = -ones(size(r));
  
else
  
  r.inversion = -r.inversion;
  
end
