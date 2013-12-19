function setLegend(h,v) 

try
  hAnnotation = get(h,'Annotation');
  hLegendEntry = get(cell2vec(hAnnotation),'LegendInformation');
  set(cell2vec(hLegendEntry),'IconDisplayStyle',v)
catch
end

function c = cell2vec(c)

if iscell(c), c = [c{:}];end
