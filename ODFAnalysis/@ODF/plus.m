function o1 = plus(o1,o2)
% superposeing two ODFs
%
% overload the + operator, i.e. one can now write @ODF + @ODF in order
% get the superposition of two ODFs
%
% See also
% ODF/ODF ODF/mtimes

if isa(o2,'double')
  
  o2 = o2 * uniformODF(o1.CS,o1.SS);  
  
elseif isa(o1,'double')
  
  o1 = o1 * uniformODF(o2.CS,o2.SS);  

elseif o1.CS ~= o2.CS
  
  error('You can not add ODFs of different crystal symmetry.')
  
elseif o1.SS ~= o2.SS
  
  error('You can not add ODFs of different specimen symmetry.')  
  
end

o1.components = [o1.components(:);o2.components(:)];
o1.weights = [o1.weights(:);o2.weights(:)];

%if any(cellfun(@(x) isa(x,'FourierComponent'),o1.components))
%  o1 = FourierODF(o1);
%end



