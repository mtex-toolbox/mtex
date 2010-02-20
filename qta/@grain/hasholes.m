function b = hasholes(grains)
% checks whether given grains has holes
%
%% Input
%  grains - @grain
%
%% Output
%  b   - boolean
%

p = polygon(grains);
b = ~cellfun('isempty',{p.hxy});

% b = false(size(grains));
% for k=1:length(grains)
%   b(k) = ~isempty(grains(k).polygon.hxy);
% end


