function omega = randomSample(psi,N,varargin)

% compute the cummulative distribution function
M = 1000000;

if check_option(varargin,'fibre')
  
  t = linspace(-1,1,M);
  c = cumsum(psi.RK(t)) / M;
  
  r = rand(N,1);
  [tmp,t] = histc(r,c);
  omega = acos(t ./ M);
  
else
  
  t = linspace(0,1,M);
  c = 4 / pi * cumsum(sqrt(1-t.^2) .* psi.K(t)) / M;
  
  r = rand(N,1);
  [tmp,t] = histc(r,c);
  omega = 2 * acos(t ./ M);
  
end


