function sVF = times(sVF, a)
% pointwise product of a vector field with a spherical function or a number
%
% Syntax
%
%   sVF = sVF .* sF % vector field times a spherical function
%   sVF = sVF .* a  % vector field times a number
%
% Input
%  sVF - @S2VectorFieldTri
%  sF  - @S2Fun
%  a   - double
%
% Output
%  sVF - @S2VectorFieldTri
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
