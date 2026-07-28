function T = rand(varargin)
% tensor with uniformly distributed random entries
%
% Description
% All entries are drawn independently from the uniform distribution on the
% interval [0,1]. The resulting tensor has in general none of the symmetries
% a physical tensor of that rank would have.
%
% Syntax
%   T = tensor.rand('rank',2)
%   T = tensor.rand('rank',4)
%   T = tensor.rand(100,'rank',2)
%   T = tensor.rand('rank',2,cs)
%
% Input
%  n,m - size of the array of tensors
%  cs  - @crystalSymmetry
%
% Options
%  rank - rank of the tensor, default is 2
%
% Output
%  T - @tensor
%
% See also
% tensor/eye tensor/zeros

r = get_option(varargin,'rank',2);
varargin = delete_option(varargin,'rank',1);
[cs,varargin] = getClass(varargin,'symmetry');
d = [repmat(3,1,r),varargin{:},1];
T = tensor(rand(d),'rank',r);
if ~isempty(cs), T.CS = cs; end
