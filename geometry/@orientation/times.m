function r = times(a,b)
% orientation times Miller and quaternion times orientation
%
%% Syntax
%  o = o1 .* o2
%  r = o .* h
%  h = inverse(o) .* r
%
%% Input
%  o - @orientation
%  h - @Miller indice
%  r - @vector3d
%
%% See also

%% orientation times vector or Miller
if isa(a,'orientation') && isa(b,'vector3d')
  
  if isa(b,'Miller'), b = ensureCS(a.CS,{b});end
  
  % rotate
  r = a.rotation .* vector3d(b);
     
  % if output has symmetry set it to Miller
  if isCS(a.SS), r = Miller(r,a.SS); end
  
%% orientation times orientation  
elseif isa(a,'quaternion') && isa(b,'quaternion')
    
  if isa(a,'orientation')
    r = a;
    a = a.rotation;
    if isa(b,'orientation')
      
      % check that symmetries are ok
      if r.CS ~= b.SS, warning('MTEX:Orientation','Symmetry mismatch!'); end
      r.CS = b.CS;
      b = b.rotation;
      
    else
      
      if length(r.CS) > 1
        warning('MTEX:Orientation','Symmetry lost!');
        r.CS = symmetry;
      end
      
    end
  else
    r = b;
    b = b.rotation;
    if length(r.SS) > 1
      warning('MTEX:Orientation','Symmetry mismatch!');
      r.SS = symmetry;
    end
  end
  
  r.rotation = a .* b;
    
%% otherwise error  
else
  
  error([class(a) ' * ' class(b) ' is not defined!'])
    
end
