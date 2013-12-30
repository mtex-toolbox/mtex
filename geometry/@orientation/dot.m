function d = dot(o1,o2)
% compute minimum dot(o1,o2) modulo symmetry

q1 = quaternion(o1);
q2 = quaternion(o2);

if ~isa(o2,'orientation') % only one input associated with symmetry
  
  qcs = o1.CS;
  qss = o1.SS;  
  
elseif ~isa(o1,'orientation')
  
  qcs = o2.CS;
  qss = o2.SS; 
  
else
  
  if o1.SS ~= o2.SS  % check specimen symmetry
    warning('MTEX:wrongSpecimenSymmetry','orientations have different specimen symmetry - check your sample!')
    qss = (o1.SS'*o2.SS);
    qss = unique(qss(:));
  else
    qss = o1.SS;
  end

  if o1.CS ~= o2.CS % check crystal symmetry
    qcs = (o1.CS'*o2.CS);
    qcs = unique(qcs(:));
  else
    qcs = o1.CS;
  end
  
end


if length(qss) == 1  % no specimen symmetry
  
  q = q1(:)'.*q2(:);
  
else % specimen symmetry 
  
  if length(q1) == length(q2)
    
  q = repmat(idquaternion,length(qss),1)*q1';    
    q = q.*(qss*q2);
  elseif length(q1) == 1
    q = inv(q1) .* (qss * q2);
  else
    q = inv(qss * q1) .* q2;
  end
  
end


if length(qcs) == 1 % no crystal symmetry
  
  d = abs(get(q,'a'));
  
else  % crystal symmetry
  
  d = max(abs(dot_outer(q,qcs)),[],2);
  
end


if length(qss) > 1 % if there was specimen symmetry
  
  d = max(reshape(d,length(qss),[]),[],1);
  
end
