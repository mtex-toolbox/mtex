function r = mtimes(a,b)
% orientation times Miller and orientation times orientation
%
%% Syntax
%  o = o1 * o2
%  r = o * h
%  h = inverse(o)*r
%
%% Input
%  o - @orientation
%  h - @Miller indice
%  r - @vector3d
%
%% See also


%% orientation times vector
if isa(a,'orientation') && isa(b,'vector3d')
  
  % check Miller has right symmery
  if isa(b,'Miller'), b = ensureCS(a.CS,{b});end
  
  % rotate
  r = a.rotation * b;
  
  % if output has symmetry set it to Miller
  if isCS(a.SS), r = Miller(r,a.SS); end
    
%% symmetry times orientation -> symmetrisation
   
elseif isa(a,'symmetry')
  
  if a ~= b.SS, warning('MTEX:Orientation','Symmetry mismatch!'); end
  
  r = b;
  r.rotation = quaternion(a) * b.rotation;
  if isCS(r.CS) || numel(r.CS)>1
    r.SS = symmetry;
  else
    r = r.rotation;
  end
  
%% orientation times symmetry -> symmetrisation  
elseif isa(b,'symmetry')
  
  if a.CS ~= b, warning('MTEX:Orientation','Symmetry mismatch!'); end
  
  r = a;
  r.rotation = a.rotation * quaternion(b);
  if isCS(r.SS) || numel(r.SS)>1
    r.CS = symmetry;
  else
    r = r.rotation;
  end
  
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
      
      if length(r.CS) > 1 && ...
          ~all(any(isappr(abs(dot_outer(b * r.CS * b^-1,r.CS)),1)))
        warning('MTEX:Orientation','Symmetry lost!');
        r.CS = symmetry;
      end
    end
  else
    r = b;
    b = b.rotation;
    if length(r.SS) > 1 && ...
        ~all(any(isappr(abs(dot_outer(a * r.SS * a^-1,r.SS)),1)))
      warning('MTEX:Orientation','Symmetry lost!');
      r.SS = symmetry;
    end
  end
  
  r.rotation = a * b;

%% otherwise error  
else
  
  error([class(a) ' * ' class(b) ' is not defined!'])
    
end
