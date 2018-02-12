function sVF = times(sVF, a)
%
% Syntax
%   sVF = sVF .* sF
%   sVF = sVF .* a
%
% Input
%  sVF - @S2VectorFieldTri
%  sF  - @S2Fun
%  a   - double
%
% Output
%  sF - @S2VectorFieldTri
%

% first should be S2VectorFieldTri
if ~isa(sVF,'S2VectorFieldTri'), [sVF,a] = deal(a,sVF); end

if isnumeric(a)
  sVF.values = sVF.values .* sVF;
elseif isa(a,'S2FunTri')
  sVF.values = sVF.values .* b.values;
else
  sVF.values = sVF.values .* b.eval(sVF.vertices);
end

end
