function d = dot(obj1,obj2)
      
d = 0;
for i = 1:length(obj1.u)
  
  id = -(1:obj1.rank(i));
  d = d + EinsteinSum(obj1.u{i},id,obj2.u{i},id);
  
end

end