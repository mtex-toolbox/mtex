function M = RK_symmetrised(psi,g,h,r,c,CS,SS,varargin)
% sum Radon trasformed kernel
%
% Syntax
%   f = RK_symmetrised(psi,g,h,r,c,CS,SS,varargin) - 
%
% Input
%  psi   - @kernel
%  g    - @quaternion(s)
%  h    - list of crystal directions
%  r    - list of ein specimen directions
%  c    - coefficients
%  CS,SS- crystal, specimen @symmetry
%
% Options
%  antipodal - antipodal Radon transform $P(h,r) = (\mathcal{R}f(h,r) + \mathcal{R}f(--h,r))/2$
%
% Output
%  matrix - 1. dim --> g, 2.dim --> r
%
% Description
% formulae
% 
% $$ f_j = \sum_i c_i \mathcal{R}K(g_i,h,r_j)$$
%
% $$ \mathcal{R}K((h,r);g) = \sum_l A_l P_l(gh, r)$$
%
% See also
% kernel/k kernel/rkk

if length(h)==1                        % pole figure
  h = unique(symmetrise(h),'noSymmetry',varargin{:});
  lh = length(h);
  in = reshape((SS * g).' * h, [length(g),numSym(SS),lh]);
	out = r;
else                                   % inverse pole figure
  in = reshape(inv(symmetrise(g)).' * r, ...
    [length(g),numSym(CS),numSym(SS)]);
  out = h; 
  lh = numSym(CS);
end

if length(in)*length(out)>500000000
  qwarning(['possible to large Matrix: ',int2str(length(in)*length(out))]);
end
M = zeros(length(out),size(in,1));
in = vector3d(in); out = vector3d(out);
 
% take mean along all symmetries
for is = 1:numSym(SS)*lh
  dmatrix = dot_outer(out.normalize,in(:,is).normalize);
  M = M + psi.RK(dmatrix);
  if check_option(varargin,'antipodal'), M = M + psi.RK(-dmatrix);end
end

if ~isempty(c), M = M * c(:); end
if check_option(varargin,'antipodal'), M = M/2;end

M = M / numSym(SS) / lh;

end