function h = hasHole(grains)


h = get(grains,'boundaryEdgeOrder');
h = cellfun('isclass',h,'cell');
