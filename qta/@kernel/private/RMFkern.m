function m = RMFkern(h,l)
% Legendrekoeffizienten des von Mieses Fischer kerns bis
% zur Entwicklungsstufe l zum Parameter h
% TODO maximum coefficient about 700

m(1) = 1;
    
for i=1:l
    m(i+1) = (2*i+1)*sqrt(pi*h/2)*...
        besseli(i+0.5,h)/sinh(h);
end
%m = m(1:length(find(m > 1E-10)));
