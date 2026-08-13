function g = grad(SO3F,varargin)
% gradient of an SO3FunCBF
%
% Syntax
%   G = SO3F.grad % compute the gradient
%   g = SO3F.grad(rot) % evaluate the gradient in rot
%
%   % go 5 degree in direction of the gradient
%   ori_new = exp(5*degree*normalize(g),rot) 
%
% Input
%  SO3F - @SO3FunCBF
%  rot  - @rotation / @orientation
%
% Output
%  G - @SO3VectorField
%  g - @vector3d
%
% Description
% general formula:
%
% $$s(g1_i) = sum_j c_j DRK(<g h_j,r_j>) g h_j x r_j $$
%
% See also
% orientation/exp SO3FunHarmonic/grad SO3FunRBF/grad SO3VectorField

% fallback to generic method
if check_option(varargin,'check') || nargin == 1 || ~isa(varargin{1},'rotation')
  g = grad@SO3Fun(SO3F,varargin{:});
  return
end

ori = varargin{1};
s = size(ori);
ori = ori(:);

% symmetrise - only crystal symmetry
[h,l] = symmetrise(SO3F.h.normalize,'unique');
r = repelem(SO3F.r.normalize,l);
w = repelem(SO3F.weights./l,l);

tS = SO3TangentSpace.extract(varargin{:});

% eval averages over the proper specimen symmetry as well as over the
% crystal symmetry - see the SS.properGroup factor in @SO3FunCBF/eval - so
% the gradient has to do the same. Leaving it out made the analytic gradient
% disagree with its own finite difference by a relative 5 for any non
% trivial specimen symmetry while agreeing to 2e-7 for SS = '1', which is
% what #2586 reported.
%
% For one symmetry element s the summand is F(s*ori), so by
% s*exp(t*v) = exp(t*(s*v))*s the two tangent spaces pick it up differently:
% the left (specimen) gradient of F(s*ori) is s^-1 times the left gradient
% of F at s*ori, while the right (crystal) gradient is just the right
% gradient of F at s*ori. Hence the inv(sRot) on the left branch only.

ssRot = rotation(SO3F.SS.properGroup);

g = vector3d.zeros(size(ori));

for k = 1:length(ssRot)

  sRot = ssRot(k);

  % rotation * vector3d lays the result out as nRot x nVec, so a single
  % symmetry element turns the column ori into a row - reshape it back, or
  % the accumulation below silently expands into a matrix
  sOri = reshape(sRot * ori,size(ori));
  gk = vector3d.zeros(size(ori));

  if tS.isRight
    for i = 1:length(h)
      gk = gk + w(i) * SO3F.psi.grad(dot(sOri*h(i),r(i),'noSymmetry'),'polynomial') .* ...
          cross(h(i),inv(sOri) * r(i));
    end
  else
    for i = 1:length(h)
      gk = gk + w(i) * SO3F.psi.grad(dot(h(i),inv(sOri) * r(i),'noSymmetry'),'polynomial') .* ...
          cross(sOri*h(i),r(i));
    end
    gk = reshape(inv(sRot) * gk,size(ori));
  end

  g = g + gk;

end

g = g ./ length(ssRot);

g = SO3TangentVector(g,ori,tS,SO3F.CS,SO3F.SS);
g = reshape(g,s);

end

function test %#ok<DEFNU>

cs = crystalSymmetry('1');
odf = fibreODF(Miller(0,0,1,cs),vector3d.Z);
%omega = linspace(-20,20)*degree;
omega = 15 *degree;
ref = orientation.byAxisAngle(vector3d(1,0,10),omega,cs) %#ok<NOPRT>


g1 = odf.grad(ref,'left')  %#ok<NOPRT>
g2 = odf.grad(ref,'check','delta',0.05*degree,'left')  %#ok<NOPRT>
  
plot(omega./degree,[g1.x,g2.x])

omega2 = linspace(-5,5)*degree;
ori1 = ref * rotation.byAxisAngle(g1,omega2);
ori2 = ref * rotation.byAxisAngle(g2,omega2);
ori3 = ref * rotation.byAxisAngle(normalize(g1+g2),omega2);
%ori4 = ref * rotation.byAxisAngle(normalize(g1-g2),'angle',omega2);
ori4 = ref * rotation.byAxisAngle(vector3d(-1,2,0),omega2);

plot(omega2./degree,[odf.eval(ori1(:)),odf.eval(ori2(:)),odf.eval(ori3(:)),odf.eval(ori4(:))])



end

function test2 %#ok<DEFNU>

  cs = crystalSymmetry('321');
  odf = fibreODF(Miller(1,2,3,cs),vector3d(-1,3,2));
  
  ref = orientation.rand(1000,cs)  %#ok<NOPRT>
  
  g1 = odf.grad(ref)  %#ok<NOPRT>
  g2 = odf.grad(ref,'check','delta',0.05*degree)  %#ok<NOPRT>
  
  histogram(norm(g1-g2)./degree)
  
  ref = orientation.id(cs) * cs(5);
  
  f = S2FunHarmonic.quadrature(@(r) ...
    odf.eval(rotation.byAxisAngle(r,5*degree)*ref));
  
  plot(f,'lower')
  
  annotate(odf.grad(ref))
end