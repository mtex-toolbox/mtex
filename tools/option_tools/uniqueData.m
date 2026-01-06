function [nodes,values] = uniqueData(nodes,values)

numNodes = numel(nodes);
values =reshape(values,numNodes,[]);

[nodes,indValues,ind] = unique(nodes(:),'stable');

% check for duplicate nodes
if numNodes > numel(nodes)

  % nodes(isnan(nodes)) = 0;

  unique_values = zeros(numel(nodes), size(values,2));
  for k = 1 : size(values,2)
    unique_values(:,k) = accumarray(ind,values(:,k),[],@mean);
  end
  values = unique_values;

else
  values = values(indValues,:);
end

end