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

% fallback to generic method
if check_option(varargin,'check')
  g = grad@ODFComponent(component,ori,varargin{:});
  return
end

% symmetrise - only crytsal symmetry
[h,l] = symmetrise(component.h.normalize);
r = repelem(component.r.normalize,l);
w = repelem(component.weights./l,l);

g = vector3d.zeros(size(ori));
for i = 1:length(h)

  % todo: scaling might not be correct
  g = g + w(i) * component.psi.DRK(dot(ori*h(i),r(i))) .* ...
    cross(h(i),inv(ori) * r(i));
end
end

function test

cs = crystalSymmetry('1');
odf = fibreODF(Miller(0,0,1,cs),vector3d.Z);
omega = linspace(-20,20)*degree;
omega = 15 *degree;
ref = orientation.byAxisAngle(vector3d(1,0,10),omega,cs)


g1 = odf.grad(ref)
g2 = odf.grad(ref,'check','delta',0.05*degree)
  
plot(omega./degree,[g1.x,g2.x])

omega2 = linspace(-5,5)*degree;
ori1 = ref * rotation.byAxisAngle(g1,omega2);
ori2 = ref * rotation.byAxisAngle(g2,omega2);
ori3 = ref * rotation.byAxisAngle(normalize(g1+g2),omega2);
%ori4 = ref * rotation.byAxisAngle(normalize(g1-g2),'angle',omega2);
ori4 = ref * rotation.byAxisAngle(vector3d(-1,2,0),omega2);

plot(omega2./degree,[odf.eval(ori1(:)),odf.eval(ori2(:)),odf.eval(ori3(:)),odf.eval(ori4(:))])



end

function test2

  cs = crystalSymmetry('321');
  odf = fibreODF(Miller(1,2,3,cs),vector3d(-1,3,2));
  
  ref = orientation.rand(1000,cs)
  
  g1 = odf.grad(ref)
  g2 = odf.grad(ref,'check','delta',0.05*degree)
  
  hist(norm(g1-g2)./degree)
  
  ref = orientation.id(cs) * cs(5);
  
  f = S2FunHarmonic.quadrature(@(r) ...
    odf.eval(rotation.byAxisAngle(r,5*degree)*ref));
  
  plot(f,'lower')
  
  annotate(odf.grad(ref))
end