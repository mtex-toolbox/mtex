function solver = doIter(solver)

% step 8 - 10 neg. gradient

% step 8 - Regularisation

for ip = 1:n

  % step 9 - c_temp <- \Psi_i (u_i odot w_i)
  if (ths->flags & WEIGHTS)
    pdf_adjoint_weights(&ths->pdf[ip],&ths->u_iter[iP],&ths->w[iP],ths->c_temp);
  else
    pdf_adjoint(&ths->pdf[ip],&ths->u_iter[iP],ths->c_temp);
  end
  
  % step 10 - tvc = <c_tmp,c>
  tvc = v_dot_double(ths->c_temp,ths->c_iter,ths->lc);

  % c_tmp <- c_tmp - alpha_i * tvc * a_i
  v_add_a_x_double(ths->c_temp,
  -ths->alpha_iter[ip]*tvc,&ths->a[ip*ths->lc],ths->lc);
    
  % g <- g - alpha_i * c_tmp
  v_add_a_x_double(ths->v_iter,-ths->alpha_iter[ip],ths->c_temp,ths->lc);
end

% step 11 - MRNDS specific gradient modification tc = c .* v 
tc_iter = c_iter .* v_iter;

% step 12 update talpha talpha_i = - 1 / a_i^t tc
for i = 1:n
  talpha_iter(i) = 1 / (a{ip} * tc_iter{ip});
end

% step 13 - regularisation
  
% step 14 tu_i <- talpha_i Psi_i tc
zbfm_mv(ths,ths->tc_iter,ths->talpha_iter,ths->tu_iter);

% tu_i <- tu_i - P
v_minus_x_y_double(ths->tu_iter,ths->tu_iter,ths->P,ths->lP);

% tu_i <- tu_i odot weights
if (ths->flags & WEIGHTS)
  v_odot_x_y_double(ths->tu_iter,ths->tu_iter,ths->w,ths->lP);

% step 15 - maximum stepsize
ind = tc_iter < 0;
tauMax = -max(c_iter(ind)./tc_iter(ind));
  
% step 16 - line search
tau = solver.lineSearch(tauMax);
  
% step 17 - update c = c + tau * tc 
c_iter = max(0,c_iter + tau * tc_iter);
        
% denominator used in step 18 and 19
denom = tau * alpha_iter + talpha_iter;

% step 18 - u_i = talpha_i/denom u_i + tau*alpha_i/denom tu_i
for ip = 1:n
  u_iter(ip) = talpha_iter(ip)/denom(ip) * u_iter(iP) + ...
    tau * alpha_iter(ip)/denom(ip) * tu_iter(ip);
end

% step 19 - alpha_i <- alpha_i talpha_i / denom 
alpha_iter = alpha_iter .* talpha_iter ./ denom;
  
end