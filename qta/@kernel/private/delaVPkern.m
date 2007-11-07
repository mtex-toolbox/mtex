function A = delaVPkern(kappa,maxl)
% Berechnet die Koeffizienten zum de la Vallee Poussin Kern

if nargin == 1
    maxl = ceil(kappa);
end

A(1) = 1;
A(2) = kappa/(kappa+2);

for l=1:maxl-1
	A(l+2) = 	((kappa-l+1)*A(l)-(2*l+1)*A(l+1))/(kappa+l+2);
end

% find position when A(l) can be assumed to be zero
ind = find(abs(A)<1E-14);
if length(ind)>1, A(ind(1):end)=0;end

for l=0:maxl
	A(l+1) = (2*l+1)*A(l+1);
end

A = A(1:sum(A > 1E-10));
