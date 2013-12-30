function p=Laplacekern(h,l)
% Legendrekoeffizienten des Poissonkerns bis
% zur Entwicklungsstufe l zum Parameter h

p(1) = 0;
for i=1:l
    p(i+1) = (2*i + 1)/(4*i^2*(2*i + 2)^2);
end
p = p(1:sum(p > 1E-10));