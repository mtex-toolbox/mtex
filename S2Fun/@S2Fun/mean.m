function value = mean(sF, varargin)
% calculates the mean value for an univariate S2Fun or calculates the mean along a specified dimension of a multimodal S2Fun
%
% Syntax
%   value = mean(sF)
%   sF = mean(sF, d)
%
% Input
%  sF - @S2FunHarmonic
%  d - dimension to take the mean value over
%
% Output
%  sF - S2FunHarmonic
%  value - double
%
% Description
%
% If sF is a 3x3 S2Fun then |mean(sF)| returns a 3x3 matrix with the mean
% values of each function mean(sF, 1) returns a 1x3 S2Fun which contains the
% pointwise means values along the first dimension
%
 
if nargin > 1 && isnumeric(varargin{1})
  
  value = S2FunHandle(@(v) mean(sF.eval(v),varargin{1}),sF.s);

else

  bw = get_option(varargin,'bandwidth',getMTEXpref('maxS2Bandwidth'));
  S2G = quadratureS2Grid(bw,'GaussLegendre');

  value = 1/(4*pi)*sum(reshape(sF.eval(S2G).*S2G.weights,[],numel(sF)),1);

  if isalmostreal(value,'componentwise')
    value = real(value);
  end
end

end
