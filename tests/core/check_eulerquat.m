%% check SO3Grid/subGrid
%
% compare subGrid function with the maxAngle option to SO3Grid
%

q = quaternion(SO3Grid(100000,symmetry,symmetry));

q = [q,-q];

[alpha,beta,gamma] = Euler(q,'Bunge');

qq = rotation.byEuler(alpha,beta,gamma,'Bunge');

e  = abs(dot(q,qq));
if mean(e) < 0.999
  hist(e);
  error('Error in euler - quaternion conversion');
else
  disp('Euler <-> quaternion conversion is ok!')
end

return

e = 0;
for i = 1:length(q)

  q1 = q(i);
  q2 = mat2quat(matrix(q(i)));
  e(i) = abs(dot(q2,q1));

end

qq = mat2quat(matrix(q));
e  = abs(dot(q,qq));

if mean(e) < 0.9
  hist(abs(e));
  error('Error in matrix - quaternion conversion');
else
  disp('matrix <-> quaternion conversion is ok!')
end
