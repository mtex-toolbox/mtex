function sF = times(sF1,sF2)
% overloads |sF1 .* sF2|
%
% Syntax
%   sF = sF1 .* sF2
%   sF = a .* sF2
%   sF = sF1 .* a
%
% Input
%  sF1, sF2 - @S2Fun
%  a - double
%
% Output
%  sF - @S2Fun
%
       
if isnumeric(sF1)
  sF = sF2;
  sF.values = times(sF1, sF.values);
  return
elseif isnumeric(sF2)
  sF = sF1;
  sF.values = times(sF1.values, sF2);
  return
end

if ~isa(sF2,'S2FunTri')
  sF2 = S2FunTri(sF1.vertices,sF2.eval(sF1.vertices));
end

if sF1.tri==sF2.tri
  sF = sF1;
  sF.values = sF1.values .* sF2.values;
else
  v = [sF1.vertices(:);sF2.vertices(:)];
  n = [sF1.values(:).*sF2.eval(sF1.vertices(:)); sF1.eval(sF2.vertices(:)).*sF2.values(:)];
  sF = S2FunTri(v,n);
end

end