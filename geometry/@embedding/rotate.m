function obj = rotate(obj,ori)
      
for i = 1:length(obj.u)
  obj.u{i} = rotate(obj.u{i},ori,'noSymCheck');
end

end