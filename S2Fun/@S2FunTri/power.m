function sF = power(sF1,sF2)
% overloads sF1.^sF2
        
if isnumeric(sF1)
  sF = sF2;
  sF.values = power(sF1, sF.values);
  return
elseif isnumeric(sF2)
  sF = sF1;
  sF.values = power(sF1.values, sF2);
  return
end


if ~isa(sF2,'S2FunTri')
  sF2 = S2FunTri(sF1.vertices,sF2.eval(sF1.vertices));
end

if sF1.tri==sF2.tri
  sF = sF1;
  sF.values = power(sF1.values,sF2.values);
else
  v = [sF1.vertices(:);sF2.vertices(:)];
  n = [sF1.values(:).^sF2.eval(sF1.vertices(:)); sF1.eval(sF2.vertices(:)).^sF2.values(:)];
  sF = S2FunTri(v,n); 
end


end
