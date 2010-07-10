function s = ClenshawL(c,x)
% Clenshaw-Algorithmus zum Aufsummieren von legendrepolynomen

% x - Auswertungspunkte
% c - Koeffizienten

% Initialisierung
dn = repmat(c(end),size(x));
d1 = zeros(size(x));
d2 = zeros(size(x));

for l = length(c)-2:-1:1
    
    
    d1 = d2 + (2*l+1)/(l+1) * x .* dn;
    d2 = c(l) - l/(l+1) * dn;
    dn = d1;
    
    %c(l+1) = c(l+1) + (2*l+1)/(l+1)*x*c(l+2);
    %c(l) =  c(l) - l/(l+1)*c(l+2);
end

dn = d2 + x .* d1;

s = dn;
