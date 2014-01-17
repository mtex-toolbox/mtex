function o1 = plus(o1,o2)
% superposeing two ODFs
%
% overload the + operator, i.e. one can now write @ODF + @ODF in order
% get the superposition of two ODFs
%
% See also
% ODF_index ODF/mtimes

if isa(o2,'double')
  
  o2 = o2 * uniformODF(o1(1).CS,o1(1).SS);  
  
elseif isa(o1,'double')
  
  o1 = o1 * uniformODF(o2(1).CS,o2(1).SS);  
  
end

o1.components = [o1.components(:);o2.components(:)];
o1.weights = [o1.weights(:);o2.weights(:)];
