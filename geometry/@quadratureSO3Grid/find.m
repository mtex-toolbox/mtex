function varargout = find(SO3G,varargin)
% return the index of the nearest node of a Clenshaw Curtis quadrature
% grid for each input rotation
%
% Since the grid is a regular tensor grid in the Euler angles the lookup
% is plain (vectorized) index arithmetic - no search is involved.
%
% The first and third Euler angle are folded into the grid section by
% their periodicity. For grids with cyclic symmetries this amounts to
% identifying symmetrically equivalent rotations, i.e. it is only
% meaningful when the data to be accumulated on the grid is (to be)
% symmetrised anyway.
%
% Syntax
%   id = find(SO3G,ori)
%
% Input
%  SO3G - @quadratureSO3Grid
%  ori  - @rotation, @orientation
%
% Output
%  id - index of the nearest node into the (unique) grid, size(ori)
%
% See also
% quadratureSO3Grid SO3FunHarmonic/adjoint

% within class methods this function also shadows the builtin find for
% ordinary arrays - delegate those calls
if ~isa(SO3G,'quadratureSO3Grid')
  [varargout{1:max(nargout,1)}] = builtin('find',SO3G,varargin{:});
  return
end

ori = varargin{1};

if ~strcmp(SO3G.scheme,'ClenshawCurtis')
  error('find is only implemented for the Clenshaw Curtis quadrature grid.')
end

N = SO3G.bandwidth;
sz = size(SO3G.iuniqueGrid);   % [nGamma × nBeta × nAlpha]

% the grid nodes are alpha,gamma = (0:n-1)*2*pi/(2N+2) and
% beta = (0:2N)*pi/(2N) in the 'nfft' Euler angle convention, which
% nfftNodesmex gives divided by 2 pi
x = nfftNodesmex(double(ori.a(:)),double(ori.b(:)),double(ori.c(:)),double(ori.d(:)),[1 1]);

ia = mod(round(x(1,:).'*(2*N+2)),sz(3));
ib = min(round(x(2,:).'*(4*N)),sz(2)-1);
ic = mod(round(x(3,:).'*(2*N+2)),sz(1));

id = SO3G.iuniqueGrid(sub2ind(sz,ic+1,ib+1,ia+1));
varargout{1} = reshape(id,size(ori));

end
