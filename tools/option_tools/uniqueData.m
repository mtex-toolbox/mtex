function [nodes,values] = uniqueData(nodes,values)

numNodes = numel(nodes);
values =reshape(values,numNodes,[]);

[nodes,indValues,ind] = unique(nodes(:));

% check for duplicate nodes
if numNodes > numel(nodes)
 
  %nodes(isnan(nodes)) = 0;
 
  values = accumarray(ind,y,[],@mean);

else

  values = values(indValues,:);
  
end



end