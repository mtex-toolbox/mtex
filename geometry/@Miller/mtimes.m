function qm = mtimes(q,m)
% implement q * Miller

if isa(q,'symmetry') || isa(q,'quaternion')
  qm = q * vector3d(m);
elseif isa(q,'Miller')
  qm = q;
  qm.h = q.h * m;
  qm.k = q.k * m;
  qm.l = q.l * m;
else
  qm = m;
  qm.h = q * m.h;
  qm.k = q * m.k;
  qm.l = q * m.l;
end
