function out = isRGB(fig)

if nargin == 0, fig = gcf; end

out = false;

ax = findall(fig,'type','axes');
childs = findobj(ax,'-property','CData');
    
if isempty(childs), return;end
    
CData = ensurecell(get(childs,'CData'));
    
out = ~isempty(CData) && any(cellfun(@(x) size(x,3)==3,CData));

end