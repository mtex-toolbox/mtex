%% check SO3Grid/subGrid
%
% compare subGrid function with the max_angle option to SO3Grid
%

q = quaternion(SO3Grid(10000,symmetry,symmetry));

[alpha,beta,gamma] = Euler(q,'Bunge');

qq = euler2quat(alpha,beta,gamma,'Bunge');

e  = abs(dot(q,qq));
if mean(e) < 0.9
  hist(e);
  error('Error in euler - quaternion conversion');
else
  disp('Euler <-> quaternion conversion is ok!')
end


e = 0;
for i = 1:length(q)
  
  q1 = q(i);
  q2 = mat2quat(quat2mat(q(i)));
  e(i) = abs(dot(q2,q1));
  
end

qq = mat2quat(quat2mat(q));
e  = abs(dot(q,qq));

if mean(e) < 0.9
  hist(abs(e));
  error('Error in matrix - quaternion conversion');
else
  disp('matrix <-> quaternion conversion is ok!')
end
  
