function psi = conv(psi1,psi2)

L = min(psi1.bandwidth,psi2.bandwidth);     
l = (0:L).';

psi = kernel(psi1.A(1:L+1) .* psi2.A(1:L+1) ./ (2*l+1));
      
end