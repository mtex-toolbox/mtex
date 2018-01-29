function doIter(solver)
%
%
% 
% 

% extract from class for quicker access
c = solver.c;
u = solver.u; 
alpha = solver.alpha;
a = solver.a;

% preallocation
talpha = cell(size(alpha));
tu = cell(size(u));

% step 8 - Regularisation
% not yet implemented

% step 9 - vt_i  = alpha_i * \Psi_i (u_i odot w_i)
vt = zeros(size(c));
for i = 1:N
  vt = vt + solver.Mtv(u,i) * alpha{i};
end

% step 10 - v = vt - alpha_i * <vt,c> * a_i
v = zeros(size(c));
for i = 1:NP
  v = v - vt{i} + alpha{i}*(vt{i} * c.') * solver.a{i};
end

% step 11 - MRNDS specific gradient modification tc = c .* v 
tc = c .* v;

% step 12 update talpha talpha_i = - 1 / a_i^t tc
for i = 1:n
  talpha{i} = 1 ./ (a{i} * tc{i});
end

% step 13 - regularisation
% todo: not yet implemented  

% step 14 tu_i = talpha_i Psi_i tc - I_i
for i = 1:NP
  tu{i} = (solver.Mv(tc,i) * talpha{i} - solver.I{i}) .* solver.weights{i};
end

% step 15 - maximum stepsize
tauMax = -max(c(tc < 0) ./ tc(tc < 0));
  
% step 16 - line search
tau = lineSearch(tauMax);
  
% step 17 - update c = c + tau * tc 
c = max(0, c + tau * tc);

% update u and alpha
for i = 1:NP
  
  % denominator used in step 18 and 19
  denom = tau * alpha{i} + talpha{i};

  % step 18 - u_i = talpha_i/denom u_i + tau*alpha_i/denom tu_i
  u{i} = talpha{i} ./ denom * u{i} + tau * alpha{i} / denom * tu{i};

  % step 19 - alpha_i <- alpha_i talpha_i / denom 
  alpha{i} = alpha{i} .* talpha{i} ./ denom;
  
end

% write back to class
solver.c  = c;
solver.u = u;
solver.alpha = alpha;

% ------------------------------------------------------------------------
function tau = lineSearch(tau)

% compute A, B, C
for j = 1:n
  A(j) = sum((u{j} * talpha{j}).^2);
  B(j) = sum((u{j} * talpha{j}) .* (tu{j} * alpha{j}));
  C(j) = sum((tu{j} * alpha{j}).^2);
end

% the line functional
J = @(tau) (A + 2*tau*B + tau*C)./(tau * alpha_iter + talpha_iter).^2;

% minimize it
tau = fminsearch(J,tau);
  
end

end
