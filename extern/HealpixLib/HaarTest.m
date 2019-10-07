% make histogram of Haar coefficients

clear

n = 32;      % grid resolution

SAMPLING = HealpixGenerateSampling(n, 'scoord');

ns = size(SAMPLING, 1);
A = zeros(ns, 1);
for t = 1:ns
    A(t) = DebugFunc(SAMPLING(t, 1), SAMPLING(t, 2));
end

WVLT = HealpixHaarTransform(A);
hist(WVLT, 60)
xlabel('Value of Haar coefficients')
ylabel('Occurrence counts')
