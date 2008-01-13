function out = mtimes(SO3G,q)
% outer quaternion multiplication
% usage:  SO3Gq = SO3G * q
%  SO3Gv = SO3G * v
%
%% Input
%  SO3G - @SO3Grid
%  q    - @quaternion 
%  v    - @vector3d
%
%% Output
%  SO3Gq - @SO3Grid
%  SO3Gv - @vector3d

if isa(SO3G,'SO3Grid')
  if isa(q,'SO3Grid'), q = q.Grid; end
  if isa(q,'quaternion')
  
    out= quaternion;
    for i = 1:length(q)
      out = [out;SO3G.Grid*q(i)];
    end
    out = SO3Grid(out,SO3G.CS,SO3G.SS);
  
  elseif isa(q,'vector3d')
    out = SO3G.Grid(:) * q;
  else
    error('type mismatch!')
  end
elseif isa(SO3G,'quaternion')
  
  out= quaternion;
  for i = 1:length(SO3G)
    out = [out;SO3G(i)*q.Grid];
  end
  out = SO3Grid(out,q.CS,q.SS);
else
  error('type mismatch!')
end

