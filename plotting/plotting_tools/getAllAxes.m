function ax = getAllAxes(fig)

h = findall(fig, ...
    '-not','Tag','Colorbar', ...
    '-and','-not','Tag','legend');

% isAxisHandle
ax = h(arrayfun(@(x) isa(x,'matlab.graphics.axis.Axes') || ...
                     isa(x,'matlab.graphics.axis.PolarAxes'), h));

end