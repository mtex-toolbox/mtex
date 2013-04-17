function q = Axis(a,n)
% quaternions for n fold symmetry axis a

q = rotation('axis',a,'angle',2*pi/n*(0:n-1));
