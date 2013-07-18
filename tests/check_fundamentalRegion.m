
n = 10000;

err2 = zeros(11);

for s1 = 1:11
  for s2 = 2:11
    CS = symmetry(s1);
    SS = symmetry(s2);
    
    q1 = randq(n);
    q2 = randq(n);
    
    o1 = orientation(q1,CS,symmetry);
    o2 = orientation(q2,SS,symmetry);
    
    [q,omega] = project2FundamentalRegion(q1,CS,SS,q2);
    
    w = angle(q,q2);
    
    omega2 = angle(o1,o2);
    
    err2(s1,s2) = norm(w(:)-omega2(:));
    
  end
end

assert(max(err2(:)) < 10e-10,'quaternion:project2FundamentalRegion',...
  'Projection to Fundamental Region failed')


