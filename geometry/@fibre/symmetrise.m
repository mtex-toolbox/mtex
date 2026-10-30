function [f,l] = symmetrise(f,varargin)
% all crystallographically equivalent fibres
%
% Syntax
%   fS = symmetrise(f)
%   [fS,l] = symmetrise(f,'unique')
%
% Description
% There is one equivalent fibre for every element g of the crystal point
% group and s of the specimen point group, about g*h through s*r. An
% improper element is no orientation: it acts on h as the rotation -g
% followed by a half turn about an axis normal to g*h, so that the arc
% keeps its length. In a centrosymmetric crystal the fibre of h||r is
% therefore that of -h||r too.
%
% Input
%  f - @fibre
%
% Output
%  fS - @fibre
%  l  - the number of equivalent fibres of every fibre in f
%
% Options
%  unique - only the distinct fibres, (h,r) and (-h,-r) being one
%
% See also
% fibre/angle fibre/multiplicity vector3d/symmetrise

if check_option(varargin,'unique')

  % the distinct images of h and the elements reaching them
  [h,lh,sym] = symmetrise(f.h,f.CS,'unique','noAntipodal');
  t = asRotation(sym(:),col(repelem(f.h(:),lh)));
  o1 = col(repelem(f.o1(:),lh)) .* inv(t);
  o2 = col(repelem(f.o2(:),lh)) .* inv(t);
  r = col(repelem(f.r(:),lh));
  src = col(repelem((1:length(f)).',lh));

  % the distinct images of r and the elements reaching them
  [~,lr,sym] = symmetrise(r,f.SS,'unique','noAntipodal');
  t = asRotation(sym(:),col(repelem(r,lr)));
  f.h = col(repelem(h(:),lr));
  f.o1 = t .* col(repelem(o1,lr));
  f.o2 = t .* col(repelem(o2,lr));
  src = col(repelem(src,lr));

  % (h,r) and (-h,-r) are one fibre
  H = normalize(vector3d(f.h)); R = normalize(f.r);
  H = [H.x(:),H.y(:),H.z(:)]; R = [R.x(:),R.y(:),R.z(:)];
  dh = H * H.'; dr = R * R.';
  same = src == src.' & ((dh > 1-1e-8 & dr > 1-1e-8) | (dh < 1e-8-1 & dr < 1e-8-1));
  keep = true(size(src));
  for k = 1:numel(keep)
    if keep(k), keep(k+1:end) = keep(k+1:end) & ~same(k+1:end,k); end
  end
  f = f.subSet(keep);
  l = accumarray(src(keep),1,[max(src),1]);

else

  % every element of the crystal point group, one row each
  S = f.CS.rot(:);
  m = numel(S); n = length(f);
  sym = repmat(S,n,1);
  h0 = reshape(repmat(reshape(f.h,1,[]),m,1),[],1);
  t = asRotation(sym,h0);
  h = sym .* h0;
  o1 = reshape(repmat(reshape(f.o1,1,[]),m,1),[],1) .* inv(t);
  o2 = reshape(repmat(reshape(f.o2,1,[]),m,1),[],1) .* inv(t);
  r = o1 .* h;

  % every element of the specimen point group
  S = f.SS.rot(:);
  k = numel(S);
  sym = repmat(S,m*n,1);
  t = asRotation(sym,reshape(repmat(reshape(r,1,[]),k,1),[],1));
  f.h = reshape(repmat(reshape(h,1,[]),k,1),[],1);
  f.o1 = t .* reshape(repmat(reshape(o1,1,[]),k,1),[],1);
  f.o2 = t .* reshape(repmat(reshape(o2,1,[]),k,1),[],1);
  l = repmat(m*k,n,1);

end

end


% the rotations acting on v as the elements s do: s itself, or for an
% improper element -s followed by a half turn about an axis normal to s*v
function t = asRotation(s,v)

s = s(:); v = vector3d(v(:));
t = rotation(quaternion(s));
imp = s.i(:);
if any(imp)
  w = s(imp) .* v(imp);
  rho = rotation.byAxisAngle(reshape(orth(w),[],1),pi);
  ti = t(imp);
  t(imp) = rho .* ti(:);
end

end


function x = col(x)
x = reshape(x,[],1);
end
