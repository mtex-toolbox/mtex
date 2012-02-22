function s = Clenshaw(c,theta,N);
% Clenshaw-Algorithmus zum Aufsummieren von assoziierten legendrepolynomen

% theta - Auswertungspunkte
% c - Koeffizienten
% 1.Dim - Auswertungspunkte
% ?? 2.Dim - Koeffizienten

pos = cumsum(2*(0:N))+1;

% Anfangsinitialisierung
s = 0;
d1 = c(pos(N+1)-N:pos(N+1)+N);
d2 = c(pos(N)-N+1:pos(N)+N-1);

for l = N:-1:2
    i = -l+1:l-1;
    ii = -l+2:l-2; 
    
    s = ((2*l-1)/(2*l))*(s + (1-theta.^2).^(l/2) ...
        *(d1(1) + d1(2*l+1)));
    
    nd = c(pos(1+l-2)-l+2:pos(1+l-2)+l-2) + ...
        sqrt((l-ii-1)./(l-ii).*(l+ii-1)./(l+ii)) .* d1(3:2*l-1);
    d1 = d2 + (2*l-1)./(l-i)/(l+i) * theta .* d1(2:2*l);
    d2 = nd;
end

% nun noch die letzten zwei Schritte ausführen

l = 1;
s = ((2*l-1)/(2*l))*(s + (1-theta.^2).^(l/2) ...
    *(d1(1) + d1(2*l+1)));
i = 0;
d1 = d2 + (2*l-1)./(l-i)/(l+i) * theta .* d1(2);    
    
%l = 0
s = s + d1 + c(1);