
n = 10000;

err2 = zeros(11);

for s1 = 1:11
  for s2 = 2:11
    CS1 = crystalSymmetry(s1);
    CS2 = crystalSymmetry(s2);
    
    q1 = quaternion.rand(n);
    q2 = quaternion.rand(n);
    
    o1 = orientation(q1,CS1,symmetry);
    o2 = orientation(q2,CS2,symmetry);
    
    [q,omega] = project2FundamentalRegion(inv(q1).*q2,CS2,CS1);
    
    w = angle(q,quaternion.id);
    
    omega2 = angle(o1,o2);
    
    err2(s1,s2) = norm(omega(:)-omega2(:));
    
  end
end

assert(max(err2(:)) < 10e-10,'quaternion:project2FundamentalRegion',...
  'Projection to Fundamental Region: FAILED')

disp('Projection to Fundamental Region: ok')


