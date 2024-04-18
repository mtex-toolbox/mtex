function s = char(ori,varargin)
% orientation to char

if isa(ori.CS,'crystalSymmetry') && isa(ori.SS,'crystalSymmetry') && ...
    isscalar(ori) && ~check_option(varargin,'Euler')
  
  [n1,n2,d1,d2] = round2Miller(ori,'maxHKL',5);
  mori_exact = orientation.map(n1,n2,d1,d2);
  
  if angle(ori,mori_exact) < 1e-3 * degree
    s = [char(n1) ' || ' char(n2) '   ' char(d1) ' || ' char(d2)];
    return
  end
  
end

s = char@rotation(ori,varargin{:});
