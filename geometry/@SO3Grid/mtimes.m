function out = mtimes(a,b)
% outer quaternion multiplication
%
%% Syntax
%  out = a * b
%  out = a * v
%
%% Input
%  a - @SO3rid
%  b - @quaternion 
%  v - @vector3d
%
%% Output
%  out - @SO3Grid / @vector3d

if isa(a,'SO3Grid') % right multiplication
  
  if isa(b,'SO3Grid'), b = b.orientation; end
    
  out = a.orientation * b;
      
elseif isa(a,'quaternion') 
  
  if numel(a) == 1 % rotate center only
    
    out = b;
    if isempty(out.center)
      out.center = a;
    else
      out.center = a * out.center;
    end
    out.orientation = a * out.orientation;
    
  else
    
    out = SO3Grid(SO3G * quaternion(b),SO3G.CS,SO3G.SS,...
        'resolution',getResolution(SO3G));            
  end
          
else
  error('type mismatch!')
end
