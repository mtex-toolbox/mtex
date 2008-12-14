function n = length(obj)

if ~isempty(obj)
  n = GridLength(obj.orientations);
else
  n = 0;
end