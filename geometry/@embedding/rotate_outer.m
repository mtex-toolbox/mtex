function obj = rotate_outer(obj,ori)
      
for i = 1:length(obj.u)
  obj.u{i} = rotate_outer(obj.u{i},ori,'noSymCheck');
end

end