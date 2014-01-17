function v = eval(k,omega)
% evaluate the kernel for given angles

v = k.K(cos(omega/2));
