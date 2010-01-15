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
  if isa(q,'Miller'), q = set(q,'CS',SO3G(1).CS);end
  q = reshape(q,1,[]);
  
  if isa(q,'quaternion') % returns quaternions
  
    out = quaternion(SO3G).' * q;
    
  elseif isa(q,'vector3d') % returns vector3d
    
    out = quaternion(SO3G).' * q;
    
  else
    error('type mismatch!')
  end
  
elseif isa(SO3G,'quaternion') 
  
  if numel(SO3G) == 1 % rotated grid
    
    for i = 1:length(q) % for all grids
      
      if isempty(q(i).center)
        q(i).center = SO3G;
      else
        q(i).center = SO3G * q(i).center;
      end
    
    end
    out = q;
    
  else
    out = SO3Grid(SO3G(:) * quaternion(q),SO3G.CS,SO3G.SS,...
        'resolution',getResolution(SO3G));            
  end
          
else
  error('type mismatch!')
end

