%% check SO3Grid/subGrid
%
% compare subGrid function with the max_angle option to SO3Grid
%

q = quaternion(SO3Grid(1000,symmetry,symmetry));

[alpha,beta,gamma] = quat2euler(q);

qq = euler2quat(alpha,beta,gamma);

if mean(abs(dot(q,qq))) < 0.9
  hist(abs(dot(q,qq)));
  error('Error in euler - quaternion conversion');
end
disp('Euler - quaternion conversion is ok!')
