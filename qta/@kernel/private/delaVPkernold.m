function A = delaVPkernold(kappa,maxl);
% Berechnet die Koeffizienten zum de la Vallee Poussin Kern

if nargin == 1
    maxl = ceil(kappa);
end

I(1) = beta(0.5,kappa+0.5);
for l = 1:maxl+1
%     if mod(l,2) == 1
%         h = Beta(0.5,kappa+l+0.5)-Beta(l+0.5,kappa+0.5);
%     else
%         h = Beta(0.5,kappa+l+0.5)+Beta(l+0.5,kappa+0.5);
%     end
    
  h = 0;  
    for k = 0:l
        
        h = h+(-1)^k * exp(...
            gammaln(2*l+1)-gammaln(2*k+1)-gammaln(2*l-2*k+1) + ...
            betaln(k+0.5,kappa+l-k+0.5));
        
        %h = h+(-1)^k * nchoosek(2*l,2*k)*Beta(k+0.5,kappa+l-k+0.5);
    end
    I(l+1) = h;
end
    
l = 0:maxl;
A = 0.5*(I(l+1)-I(l+2))./beta(1.5,kappa+0.5);
