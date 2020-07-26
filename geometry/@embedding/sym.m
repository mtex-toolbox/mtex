function obj = sym(obj)
% the symmetric part of the tensors
      
for i = 1:length(obj.u)
  if  obj.rank(i) > 1
    obj.u{i} = sym(obj.u{i});
  end
end

end