function q = Axis(a,n)
% quaternions for n fold symmetry axis a

q = axis2quat(a,2*pi/n*(0:n-1));
