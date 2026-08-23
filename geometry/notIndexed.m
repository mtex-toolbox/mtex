classdef notIndexed < phaseItem
% class representing a not indexed phase
%
% The placeholder that sits in the CSList of a @phaseList wherever a phase
% could not be indexed. It is a @phaseItem like a @crystalSymmetry, but
% carries no lattice and reports isIndexed as false.
%
% Syntax
%   ni = notIndexed
%   ni = notIndexed(name)
%   ni = notIndexed(name,color)
%
% Input
%  name  - name shown instead of a mineral, 'notIndexed' by default
%  color - RGB triplet, NaN by default
%
% Class Properties
%  mineral   - the name
%  color     - RGB triplet
%  isIndexed - always false
%
% See also
% phaseItem phaseList crystalSymmetry
%

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