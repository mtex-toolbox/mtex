function C = rand(varargin)
% random stiffness tensor
%
% Description
% The entries of a stiffness tensor cannot be drawn independently: it has
% to be symmetric and positive definite, which a tensor of independent
% random entries is not, and which this class checks on construction. The
% Voigt matrix is therefore drawn as a random Gram matrix $A A^T$, shifted
% away from singularity, so that both properties hold by construction.
%
% Note that there are no |zeros|, |ones| or |nan| counterparts, since none
% of those is a stiffness tensor.
%
% Syntax
%   C = stiffnessTensor.rand
%   C = stiffnessTensor.rand(100)
%   C = stiffnessTensor.rand(cs)
%
% Input
%  n,m - size of the array of tensors
%  cs  - @crystalSymmetry
%
% Output
%  C - @stiffnessTensor
%
% See also
% stiffnessTensor.stiffnessTensor tensor/rand

[cs,varargin] = getClass(varargin,'symmetry');

% dispatch is on the argument class, so rand(6) below is the builtin and
% not this method
n = prod([varargin{:},1]);
M = zeros(6,6,n);
for k = 1:n
  A = rand(6);
  M(:,:,k) = A*A.' + 6*eye(6);
end

C = stiffnessTensor(M);

% assigning it afterwards, as tensor.rand does - an empty cs passed to
% the constructor would be read as an option name
if ~isempty(cs), C.CS = cs; end

if ~isempty(varargin), C = reshape(C,[varargin{:},1,1]); end
