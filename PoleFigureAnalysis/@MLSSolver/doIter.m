function doIter(solver)
% perform one iteration step of the modified least squares algorithm
%

% shall we do regularization?
doReg = ~isempty(solver.RM);

% extract from class for quicker access
c = solver.c;
u = solver.u; 
alpha = solver.alpha;
a = solver.a;
n = length(solver.refl); % number of pole figures

% preallocation
talpha = zeros(size(alpha));
tu = cell(size(u));

% steps 8 - 10: compute gradient v
% step 8: regularization
if doReg
  v = alpha(n+1) * u{n+1} - alpha(n+1).^2 * (u{n+1} .* solver.c);
else
  v = zeros(size(c));  
end

for i = 1:n
  % step 9: vt_i  = alpha_i * \Psi_i (u_i odot w_i)
  vti = alpha(i) * solver.Mtv(u{i}.*solver.weights{i},i);
  
  % step 10: v = vt - alpha_i * <vt,c> * a_i
  v = v - vti + alpha(i) * (vti.' * c) * solver.a{i};
end

% step 11: MRNDS specific gradient modification tc = c .* v 
tc = c .* v;

% step 12: update talpha
for i = 1:n
  talpha(i) = 1 ./ (a{i}.' * tc);
end

% step 13: regularization
if doReg
  talpha(n+1) = 1./sum(tc);
  tu{n+1} = talpha(n+1) * (solver.RM * tc); 
end

% step 14 tu_i = talpha_i Psi_i tc - I_i
for i = 1:n
  tu{i} = (talpha(i) * solver.Mv(tc,i) - solver.pf.allI{i}(:)) .* solver.weights{i};  
end

% step 15: maximum stepsize to ensure non negativity of c
tauMax = -max(c(tc < 0) ./ tc(tc < 0));
  
% step 16: line search
tau = lineSearch(tauMax);
  
% step 17: update c = c + tau * tc 
c = max(c + tau * tc, 0);

% denominator used in step 18 and 19
denom = alpha * tau + talpha;

% step 18: u_i = talpha_i/denom u_i + tau*alpha_i/denom tu_i
for i = 1:n + doReg
  u{i} = (talpha(i) ./ denom(i)) * u{i} + (tau * alpha(i) / denom(i)) * tu{i}; 
end

% step 19 - alpha_i <- alpha_i talpha_i / denom 
alpha = alpha .* talpha ./ denom;

% write back to class
solver.c  = c;
solver.u = u;
solver.alpha = alpha;

% ------------------------------------------------------------------------
function tau = lineSearch(tauMax)

% compute A, B, C
A = zeros(1,n+doReg); B = zeros(1,n+doReg); C = zeros(1,n+doReg);
for j = 1:n
  A(j) = talpha(j)^2 * sum(u{j}.^2);
  B(j) = talpha(j) * alpha(j) * (u{j}.' * tu{j});
  C(j) = alpha(j)^2 *sum(tu{j}.^2);
end

if doReg
  A(n+1) = talpha(n+1).^2 * alpha(n+1) * (solver.c.' * u{n+1});
  B(n+1) = talpha(n+1).^2 * alpha(n+1) * (tc.' * u{n+1});
  C(n+1) = talpha(n+1) * alpha(n+1)^2 * (tc.' * tu{n+1});
end

% the candidates
nc = 200;
tau = reshape(tauMax * 0.95.^(0:nc-1),[],1);
%tau = 10*[-tau;0;flipud(tau)]; nc = 2*nc+1;

% the line functional
J = sum((repmat(A,nc,1) + 2*tau*B + tau.^2 * C)./(tau * alpha + repmat(talpha,nc,1)).^2,2);

% minimize it
[~,id] = min(J);
tau = tau(id);

end

end
