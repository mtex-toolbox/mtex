function t = randomSample(psi,N,varargin)

% compute the cummulative distribution function
t = linspace(-1,1,1000);
c = cumsum(sqrt(1-t.^2) .* psi.K(t));

% 
r = rand(N,1);
[tmp,t] = histc(r,c);

