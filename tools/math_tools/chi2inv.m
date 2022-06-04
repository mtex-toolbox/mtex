function x = chi2inv(p,nu)
% Inverse-chi-squared distribution
% x = Gamma(nu/2,1/(2*p)) / Gammma(nu/2)

x = gammainc(1/(2*p),nu/2) / gamma(nu/2);

end