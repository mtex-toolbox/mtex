function sF = times(sF1,sF2)
% overloads sF1 .* sF2
%
% Syntax
%   sF = sF1.*sF2
%   sF = a.*sF1
%   sF = sF1.*a
%
% Input
%  sF1, sF2 - S2FunHarmonic
%  a        - double
%
% Output
%  sF - S2FunHarmonic
%

if isnumeric(sF1) 
  sF = sF2;
  sF.fhat = reshape(sF1,[1 size(sF1)]) .* sF.fhat;
  return
end
if isnumeric(sF2)
  sF = sF1;
  sF.fhat = sF.fhat .* reshape(sF2,[1 size(sF2)]);
  return
end

if isa(sF2,'S2FunHarmonic')
  bw = min(getMTEXpref('maxS2Bandwidth'),sF1.bandwidth + sF2.bandwidth);
else
  bw = getMTEXpref('maxS2Bandwidth');
end
f = @(v) sF1.eval(v) .* sF2.eval(v);

if isa(sF1,'S2VectorField') || isa(sF2,'S2VectorField')
  sF = S2VectorFieldHarmonic.quadrature(f, 'bandwidth', bw);
elseif isa(sF1,'S2AxisField') || isa(sF2,'S2AxisField')
  sF = S2AxisFieldHarmonic.quadrature(f, 'bandwidth', bw);
else
  sF = S2FunHarmonic.quadrature(f, 'bandwidth', bw);
end

end
