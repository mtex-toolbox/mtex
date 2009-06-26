function out = mtimes(SO3G,q)
% outer quaternion multiplication
%% Syntax
%  SO3Gq = SO3G * q
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

if isa(SO3G,'SO3Grid') % right multiplication
  if isa(q,'SO3Grid'), q = quaternion(q); end
  if isa(q,'Miller'), q = vector3d(q,SO3G(1).CS);end
  q = reshape(q,1,[]);
  if isa(q,'quaternion')
  
    if numel(q) == 1
      for i = 1:length(SO3G)
        if isempty(SO3G(i).center)
          SO3G(i).center = q;
        else
          SO3G(i).center = SO3G(i).center * q;
        end
      end
      out = SO3G;
    else      
      out = SO3Grid(quaternion(SO3G).' * q,SO3G.CS,SO3G.SS,...
        'resolution',getResolution(SO3G));            
    end
  elseif isa(q,'vector3d')
    out = quaternion(SO3G).' * q;
  else
    error('type mismatch!')
  end
elseif isa(SO3G,'quaternion')
  
  out = SO3Grid(SO3G(:) * quaternion(q),q.CS,q.SS,...
    'resolution',getResolution(q));
  
else
  error('type mismatch!')
end

