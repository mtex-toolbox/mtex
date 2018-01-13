function tau = lineSearch(solver,tau)

% compute A, B, C
for ip = 1:n
  A(ip) = talpha_iter(ip)^2 * sum(u_iter(ip).^2);
  B(ip) = alpha_iter(ip) * talpha_iter(ip) * ...
    sum(u_iter(ip) .* tu_iter(ip));
  C(ip) = alpha_iter(ip).^2 * sum(tu_iter(ip).^2);
end

% the line functional
J = @(tau) (A + 2*tau*B + tau*C)./(tau * alpha_iter + talpha_iter).^2;

% minimize it
tau = fminsearch(J,tau);
  
end