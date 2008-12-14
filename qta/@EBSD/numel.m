function n = numel(obj)

if ~isempty(obj)
  n = numel(obj.orientations);
else 
  n = 0;
end