function p=APkern(h,l)
% Legendrekoeffizienten des Poissonkerns bis
% zur Entwicklungsstufe l zum Parameter h

p = ones(1,l+1);

for i=1:l
    p(i+1) = (2*i+1)*exp(log(h)*2*i);
end
p = p(1:sum(p > 1E-15));
