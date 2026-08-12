function C = rand(varargin)
% random compliance tensor
%
% Description
% As for <stiffnessTensor.rand.html stiffnessTensor.rand>, the entries
% cannot be drawn independently: a compliance tensor has to be symmetric
% and positive definite, and this class checks that on construction. The
% Voigt matrix is drawn as a random Gram matrix $A A^T$, shifted away from
% singularity.
%
% Note that there are no |zeros|, |ones| or |nan| counterparts, since none
% of those is a compliance tensor.
%
% Syntax
%   S = complianceTensor.rand
%   S = complianceTensor.rand(100)
%   S = complianceTensor.rand(cs)
%
% Input
%  n,m - size of the array of tensors
%  cs  - @crystalSymmetry
%
% Output
%  S - @complianceTensor
%
% See also
% complianceTensor/eye stiffnessTensor/rand

[cs,varargin] = getClass(varargin,'symmetry');

% dispatch is on the argument class, so rand(6) below is the builtin and
% not this method
n = prod([varargin{:},1]);
M = zeros(6,6,n);
for k = 1:n
  A = rand(6);
  M(:,:,k) = A*A.' + 6*eye(6);
end

C = complianceTensor(M);

% assigning it afterwards, as tensor.rand does - an empty cs passed to
% the constructor would be read as an option name
if ~isempty(cs), C.CS = cs; end

if ~isempty(varargin), C = reshape(C,[varargin{:},1,1]); end
