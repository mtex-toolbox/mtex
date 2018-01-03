function sF = transpose(sF)
% transposes S2FunHarmonic

dim = length(size(sF));
sF.fhat = permute(sF.fhat, [1 3 2 4:dim+1]);

end
