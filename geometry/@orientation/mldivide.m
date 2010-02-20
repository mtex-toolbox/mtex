function r = mldivide(a,b)
% o \ v 


if isa(b,'vector3d')

  r = Miller(a.rotation \ b,a.CS);

elseif isa(a,'orientation') && isa(b,'orientation')
  % solve (a*q = b) modulo symmetry
  % -> (a*CS)*q = (b*CS)
  % ->        q = (a*CS)'*(b*CS)
  
  if (a.CS == b.CS)
 
    r = repmat(a.rotation',length(a.CS),1).*symmetrise(b);
  
    [omega r] = selectMinbyColumn(angle(r.rotation),r);
    
  else
    
    error('symmetry mismatch')
    
  end
 
else
  
  error([class(a) ' \ ' class(b) ' is not defined!'])
  
end
