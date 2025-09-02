function exponents = get_monomial_exponents(degs)

% given a polynomial degree, return the monomial coefficients of all monomials
% of this degree


% input: 
%   deg - the prescribed degree
%         double or array (one or multiple degrees might be specified)

% output:
%   exponents - 

% examples:
%   exponents = get_monomial_exponents(3);
%   exponents = get_monomial_exponents((0:3));
%   exponents = get_monomial_exponents((1:2:3)); % if only odd degs are needed


k = numel(degs);

% get overall size of resulting exponents vector
totalsize = sum(deg2dim(degs));
exponents = zeros(totalsize, 3);

idx = 0;
for i = 1 : k
  deg = degs(i);
  
  % degree 0 is easy
  if (deg == 0)
    exponents(idx+1,:) = zeros(1,3);
    idx = idx + 1;
    continue;
  end

  % with z-exponent 1
  tempdim = deg;
  dividers = [zeros(tempdim,1), nchoosek((1:deg)',1),ones(tempdim,1)*(deg+1)];
  exponents(idx+1 : idx+tempdim, :) = [diff(dividers, 1, 2) - 1, ones(tempdim, 1)];
  idx = idx + tempdim;

  % with z-exponent 0
  tempdim = deg+1;
  dividers = [zeros(tempdim,1), nchoosek((1:deg+1)',1),ones(tempdim,1)*(deg+2)];
  exponents(idx+1 : (idx + tempdim), :) = [diff(dividers, 1, 2) - 1, zeros(tempdim, 1)];
  idx = idx + tempdim;

end

end


function dim = deg2dim(deg)
  dim = 2 * deg + 1;
end