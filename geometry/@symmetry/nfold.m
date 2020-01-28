function n = nfold(cs,axis)
% maximal n-fold of symmetry axes

if nargin == 1
  switch cs.LaueName
    case {'112/m','2/m11','12/m1','mmm'}
      n = 2;
    case {'m-3','-3','-3m1','-31m'}
      n = 3;
    case {'4/m','4/mmm','m-3m'}
      n = 4;
    case {'6/m','6/mmm'}
      n = 6;
    otherwise
      n = 1;
  end
else
  axis = vector3d(axis);
  n = ones(size(axis));
  for i = 1:length(axis)
    ind = isnull(angle(cs.rot.axis,axis(i))) & cs.rot.angle>0;
    if any(ind(:))
      n(i) = 2*pi / min(cs.rot(ind).angle);
    end
  end
  
end
