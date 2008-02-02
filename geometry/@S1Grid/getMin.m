function m = getMin(G)
% return minimum value

%m = arrayfun(@(x) ,G)
m = zeros(size(G));
%for i = 1:numel(G)
%  m(i) = G(i).min;
%end
m = [G.min];
