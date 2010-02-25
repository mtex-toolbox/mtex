function r = mldivide(a,b)
% o \ v 


if isa(b,'vector3d')

  r = Miller(a.rotation \ b,a.CS);

elseif isa(a,'orientation') && isa(b,'orientation')
  % solve (a*q = b) modulo symmetry
  % -> (a*CS)*q = (b*CS)
  % ->        q = (a*CS)'*(b*CS)
  
  if (a.CS == b.CS)
 
    if numel(b) == 1 && numel(a) ~= numel(b),
      b.rotation = repmat(b.rotation,size(a));
    elseif numel(a) == 1 && numel(a) ~= numel(b),
      a.rotation = repmat(a.rotation,size(b));
    end
    
    r = repmat(a.rotation',length(a.CS),1).*symmetrise(b);
  
    [omega r] = selectMinbyColumn(angle(r.rotation),r);
    
  else
    
    error('symmetry mismatch')
    
  end
  
elseif isa(a,'orientation') && ~isa(b,'orientation') && isa(b,'quaternion')
  r = a \ orientation(b,a.CS,a.SS);
elseif isa(b,'orientation') && ~isa(a,'orientation') && isa(a,'quaternion')
  r = orientation(a,b.CS,b.SS) \ b;
else
  
  error([class(a) ' \ ' class(b) ' is not defined!'])
  
end
