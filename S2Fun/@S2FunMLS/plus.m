function sF = plus(sF1, sF2)

% implements sF1 + sF2
%
% Syntax
%   sF = sF1 + sF2
%   sF = a + sF1
%   sF = sF1 + a
%

if isnumeric(sF1) && isscalar(sF1)
  sF = sF2;
  sF.values = sF2.values + sF1;
  return;
end

if isnumeric(sF2) && isscalar(sF2)
  sF = sF1;
  sF.values = sF1.values + sF2;
  return;
end

if (isa(sF2, 'S2FunHarmonic'))
  sF = sF2 + sF1;
  return;
end

if ~isa(sF2,'S2FunMLS')
  sF = plus@S2Fun(sF1,sF2);
  return
end


if (sF1.nodes ~= sF2.nodes)
  error('Addition of S2FunMLS only works if the grids are the same.');
end

sF = sF1;
sF.values = sF1.values + sF2.values;

end