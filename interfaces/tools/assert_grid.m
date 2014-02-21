function assert_grid(theta_start,theta_delta,theta_end,rho_start,rho_delta,rho_end,varargin)
% check for valid grid parameters

if check_option(varargin,'degree')
  stop = 180;
else
  stop = pi;
end
  
assert(theta_start>=0 && theta_start <= theta_end && theta_end<=stop &&...
  theta_delta > 0 && theta_delta <= theta_end - theta_start && ...
  rho_start>=0 && rho_start < rho_end && rho_end<=2*stop &&...
  rho_delta > 0 && rho_delta <= rho_end - rho_start);
