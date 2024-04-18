function sF = conj(sF)
% conjugate S1FunHarmonic

sF.fhat = conj(flip(sF.fhat,1));

end
