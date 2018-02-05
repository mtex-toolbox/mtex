function g = grad(component,ori,varargin)
% evaluate an odf at orientation g
%
% Syntax
%   g = grad(component,ori)
%
% Input
%  component - @fibreComponent
%  ori - @orientation
%
% Output
%  g - @vector3d
%
% Description
% general formula:
%
% $$s(g1_i) = sum_j c_j DRK(<g h_j,r_j>) g h_j x r_j $$

% symmetrise - only crytsal symmetry
[h,l] = symmetrise(component.h.normalize);
r = rep(component.r.normalize,l);
w = rep(component.weights./l,l);

g = vector3d.zeros(size(ori));
for i = 1:length(h)

  % todo: scaling might not be correct
  g = g + w(i) * component.psi.DRK(dot(ori*h(i),r(i))) .* ...
    cross(ori * h(i), r(i));
end
end

function test

  cs = crystalSymmetry('321');
  odf = fibreODF(Miller(1,2,3,cs),vector3d(-1,3,2));
  
  ref = orientation.id(cs) * cs(5);
  
  f = S2FunHarmonic.quadrature(@(r) ...
    odf.eval(rotation('axis',r,'angle',5*degree)*ref));
  
  plot(f,'lower')
  
  annotate(odf.grad(ref))
end