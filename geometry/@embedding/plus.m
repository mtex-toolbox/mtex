function obj1 = plus(obj1,obj2)
% sum of two embeddings
      
for i = 1:length(obj1.u)
  obj1.u{i} = obj1.u{i} + obj2.u{i};
end

end