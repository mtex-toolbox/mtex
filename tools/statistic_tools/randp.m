function r = randp(lambda)
% randp(lambda) returns Poisson distributed Vector with mean lambda

try
  r = poissrnd(lambda);
  return
end

lambda   = reshape(lambda,1,[]);
aktiv    = find(lambda > 1e-10);
ll       = log(lambda(aktiv));
r(aktiv) = rand(1,length(aktiv));
r(find(lambda < 1e-10)) = 0;

i = 0;
while length(aktiv) > 0
		r(aktiv) = r(aktiv) - exp(i*ll - lambda(aktiv) - gammaln(i+1));
		ind = find(r(aktiv)<=0);
		r(aktiv(ind)) = i;
		aktiv(ind) = [];
		ll(ind) = [];
		i = i + 1;
end

