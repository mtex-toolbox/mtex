function nodf = rotate(odf,q)
% rotate ODF
%
%% Input
%  odf - @ODF
%  q   - @quaternion
%
%% Output
%  rotated odf - @ODF

nodf = odf;

for i = 1:length(odf)
  if check_option(odf(i),'FIBRE')
    
    nodf(i).center{2} = q * nodf(i).center{2};
    
  elseif check_option(odf(i),'FOURIER')
    
    L = bandwidth(odf(i));
    D = wignerD(q,'bandwidth',L);
    
    for l = 0:L
      nodf(i).c_hat(deg2dim(l)+1:deg2dim(l+1)) = ...
        reshape(D(deg2dim(l)+1:deg2dim(l+1)),2*l+1,2*l+1) * ...
        reshape(nodf.c_hat(deg2dim(l)+1:deg2dim(l+1)),2*l+1,2*l+1);
    end
    
  elseif ~check_option(odf(i),'UNIFORM')
    
    nodf(i).center = q * nodf(i).center;
    
  end
end


function d = deg2dim(l)
% dimension of the harmonic space up to order l

d = l*(2*l-1)*(2*l+1)/3;
