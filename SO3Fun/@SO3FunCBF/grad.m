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

% symmetrise the crystal directions
[h,l] = symmetrise(SO3F.h.normalize,'unique');
r = repelem(SO3F.r.normalize,l);
w = repelem(SO3F.weights./l,l);

g = vector3d.zeros(size(ori));

tS = SO3TangentSpace.extract(varargin{:});

% eval averages over the proper specimen group as well - see SO3FunCBF/eval -
% and the gradient has to follow it, otherwise it describes a different
% function. Since <s*g*h,r> = <g*h,inv(s)*r>, a specimen operation is the
% same sum with r replaced by inv(s)*r, so the formulas below are unchanged.
sProper = SO3F.SS.properGroup.rot;
nS = numel(sProper);

for k = 1:nS

  % one rotation times a column of vectors comes back as a row, so put the
  % shape back before indexing it alongside h and w
  rS = reshape(inv(sProper(k)) * r(:),[],1);

  if tS.isRight
    for i = 1:length(h)
      g = g + w(i)/nS * SO3F.psi.grad(dot(ori*h(i),rS(i),'noSymmetry'),'polynomial') .* ...
          cross(h(i),inv(ori) * rS(i));
    end
  else
    for i = 1:length(h)
      g = g + w(i)/nS * SO3F.psi.grad(dot(h(i),inv(ori) * rS(i),'noSymmetry'),'polynomial') .* ...
          cross(ori*h(i),rS(i));
    end
  end

end

g = SO3TangentVector(g,orientation(ori,SO3F.CS,SO3F.SS),tS);
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