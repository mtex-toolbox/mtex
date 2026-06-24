classdef notIndexed < phaseItem
% class representing a not indexed phase  

  methods
    function obj = notIndexed(name,color)
      obj.isIndexed = false;
      obj.mineral = 'notIndexed';
      obj.color = [NaN NaN NaN];
      if nargin >= 1, obj.mineral = name; end
      if nargin >= 2, obj.color = color; end
    end
  end
end