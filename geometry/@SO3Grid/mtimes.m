function out = mtimes(a,b,varargin)
% outer quaternion multiplication
%
% Syntax
%   out = a * b
%   out = a * v
%
% Input
%  a - @SO3Grid
%  b - @quaternion 
%  v - @vector3d
%
% Output
%  out - @SO3Grid / @vector3d

if isa(a,'SO3Grid') % right multiplication
  
  if isa(b,'SO3Grid'), b = orientation(b); end
    
  out = orientation(a) * b;
      
elseif isa(a,'quaternion') 
  
  if length(a) == 1 % rotate center only
    
    r = mtimes@orientation(a,b);
    out = b;
    out.a = r.a;
    out.b = r.b;
    out.c = r.c;
    out.d = r.d;
    out.i = r.i;
    if isempty(b.center)
      out.center = a;
    else
      out.center = a * out.center;
    end
        
  else
    
    out = a * orientation(b);
    
  end
          
else
  error('type mismatch!')
end
