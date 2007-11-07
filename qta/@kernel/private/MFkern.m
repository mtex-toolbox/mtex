function m = MFkern(h,l)
% Legendrekoeffizienten des von Mieses Fischer kerns bis
% zur Entwicklungsstufe l zum Parameter h

m(1) = 1;
for i=1:l
    m(i+1) = (besseli(i,h)-besseli(i+1,h))/(besseli(0,h)-besseli(1,h));
end
%m = m(1:length(find(m > 1E-10)));
