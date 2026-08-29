function fr = loadobj(s)
% a saved notIndexed phase is the frame of the same name
%
% It carried a name and a colour and nothing else, and notIndexedFrame takes
% both in that order.

if isa(s,'notIndexedFrame'), fr = s; return; end

name = 'notIndexed';
if isfield(s,'mineral') && ~isempty(s.mineral), name = s.mineral; end
if isfield(s,'name') && ~isempty(s.name), name = s.name; end

if isfield(s,'color') && numel(s.color) == 3
  fr = notIndexedFrame(name,s.color);
else
  fr = notIndexedFrame(name);
end

end
