function [nodes,values] = uniqueData(nodes,values)

numNodes = numel(nodes);
values =reshape(values,numNodes,[]);

[nodes,indValues,ind] = unique(nodes(:),'stable');

% check for duplicate nodes
if numNodes > numel(nodes)
 
  %nodes(isnan(nodes)) = 0;
 
  values = accumarray(ind,values,[],@mean);

else

  values = values(indValues,:);
  
end



end