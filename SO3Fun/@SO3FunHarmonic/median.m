function value = median(SO3F, varargin)
% Calculates an approximate median value of a SO3FunHarmonic by using the first Wigner
% coefficient, i.e.
%
% $$ median(f) = \hat{f}_0^{0,0} = \frac1{8\pi^2} \int_{SO(3)} f(R) dR $$,
% 
% where vol(SO(3)) = \int_{SO(3)} 1 dR = 8\pi^2$.
% 
% or calculates the median along a specified dimension of a 
% vector-valued SO3Fun.
%
% Syntax
%   value = median(SO3F)
%   SO3F  = median(SO3F, d)
%
% Input
%  SO3F - @SO3FunHarmonic
%  d    - dimension to take the median value over
%
% Output
%  SO3F  - @SO3FunHarmonic
%  value - double
%
% Description
%
% If SO3F is a 3x3 SO3Fun then
% |median(SO3F)| returns a 3x3 matrix with the median values of each function
% |median(SO3F, 1)| returns a 1x3 SO3Fun which contains the pointwise median values along the first dimension
%


s = size(SO3F);

% median along a specific dimension
if nargin > 1 && isnumeric(varargin{1})
    dim = varargin{1};
    sortedValues = sort(SO3F, dim);
    midIdx = ceil(size(sortedValues, dim) / 2);
    if dim == 1
        value = sortedValues(midIdx, :);
    else
        value = sortedValues(:, midIdx);
    end
    return
end


SO3F = SO3F.subSet(':');
value = SO3F.fhat(1, :);
value = reshape(value, s);

if isalmostreal(value, 'componentwise')
    value = real(value);
end

end