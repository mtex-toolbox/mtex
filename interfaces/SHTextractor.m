function sF = SHTextractor(file)
% Extract the corresponding S2FunHarmonic of an SHT file.
% examples of SHT files can be finded at 
% https://github.com/EMsoft-org/SHTdatabase/tree/master/EBSD
%
% Syntax
%   sF = SHTextractor(file)
%
% Input
%  file - path/name of SHT-File
%
% Output
%  sF - @S2FunHarmonic
%

% Read Data from SHT-File into matlab
[coeff,sym] = SHTextractormex(file);

% bandwidth
bw = sqrt(length(coeff))-1;

% reconstruct Fourier coefficients (some are left in SHT-file because
% they are symmetric  since sF is a real valued functions)
coeff = reshape(coeff,bw+1,bw+1);
coeff = [flip(coeff(:,2:end),2) , coeff];
fhat = zeros(bw^2,1);
for n=0:bw
  fhat(n^2+(1:2*n+1)) = coeff(n+1,bw+1+(-n:n)).';
end

try
  % Get Symmetry
  cs = crystalSymmetry('SpaceId',sym.SpaceId,sym.LatticeParameters(1:3),sym.LatticeParameters(4:6)*degree,'mineral',sym.Mineral);
  % Construct Function
  sF = S2FunHarmonicSym(fhat,cs,'skipSymmetrise');
catch
  sF = S2FunHarmonic(fhat);
end

end