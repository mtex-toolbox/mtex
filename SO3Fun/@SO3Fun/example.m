function f = example(varargin)

if nargin == 0 || ~isa(varargin{1},'rotation')
  if check_option(varargin,'exact')
    f = SO3FunHandle(@(ori) SO3Fun.example(ori));
  else
    %SRight = specimenSymmetry;
    %SLeft = SRight;
    f = SO3FunHarmonic.quadrature(@(ori) SO3Fun.example(ori),varargin{:});
  end
  return;
end

ori = varargin{1};
ori = ori(:);

% c0=15;
% r=100*degree;
% E = [180,90,180];
% centers = rotation.byEuler(E*degree);
% f1 = @(ori) c0.*(r-angle(ori,centers)).*(angle(ori,centers)<r);


ss=specimenSymmetry('1');
cs=crystalSymmetry('23');
warning('off')
odf = fibreODF(fibre.beta(cs,ss),'halfwidth',5*degree).*orientation.byEuler(20*degree,10*degree,70*degree);
f2 = @(ori) odf.eval(ori);
f = f2(ori);
warning('on');
%mtexdata dubna
%odf = pf.calcODF;
%fh = @(ori) odf.eval(ori);
%f=fh(ori);

end


% function A = fan(ori,centers)
%   A = zeros(length(ori),length(centers));
%   for j=1:length(centers)
%     A(:,j) = angle(ori,centers(j));
%   end
% end
% 



