function [nodes,values] = uniqueData(nodes, values, varargin)

numNodes = numel(nodes);
values = reshape(values, numNodes, []);

[nodes, indValues, ind] = unique(nodes(:),'stable');

% check for duplicate nodes
if numNodes > numel(nodes)

  % nodes(isnan(nodes)) = 0;

  % allow use of other function then mean for combinining multiple values of the
  %   same node into 1 
  if nargin > 0 
    if isa(varargin{1}, 'function_handle')
      fun = varargin{1};
    elseif isa(varargin{1}, 'char')
      try 
        fun = str2func(varargin{1});
      catch
        error('Unknown function name');
      end
    end
  else
    fun = @mean;
  end

  unique_values = zeros(numel(nodes), size(values,2));
  for k = 1 : size(values,2)
    unique_values(:,k) = accumarray(ind, values(:,k), [], fun);
  end
  values = unique_values;

else
  values = values(indValues,:);
end

end