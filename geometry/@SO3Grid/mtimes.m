function out = mtimes(SO3G,q)
% outer quaternion multiplication
%
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
  
  if isa(q,'SO3Grid'), q = q.orientation; end
    
  out = SO3G.orientation * q;
      
elseif isa(SO3G,'quaternion') 
  
  if numel(SO3G) == 1 % rotated grid
    
    out = q;
    if isempty(out.center)
      out.center = SO3G;
    else
      out.center = SO3G * out.center;
    end
    q.orientation = SO3G * q.orientation;
    
  else
    
    out = SO3Grid(SO3G * quaternion(q),SO3G.CS,SO3G.SS,...
        'resolution',getResolution(SO3G));            
  end
          
else
  error('type mismatch!')
end
