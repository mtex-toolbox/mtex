classdef notIndexedFrame < referenceFrame
% the frame of measurements that could not be indexed
%
% It sits in the CSList of a @phaseList wherever a measurement was not
% indexed. Being a @referenceFrame is what lets one list hold it beside the
% @crystalFrame of every indexed phase; it carries no lattice, and
% |isIndexed| reads false for it and true for every other frame.
%
% Syntax
%   ni = notIndexedFrame
%   ni = notIndexedFrame(name)
%   ni = notIndexedFrame(name,color)
%
% Input
%  name  - name shown instead of a mineral, 'notIndexed' by default
%  color - RGB triplet, NaN by default
%
% Class Properties
%  name, mineral - the name
%  color         - RGB triplet
%  isIndexed     - always false
%
% See also
% referenceFrame phaseList crystalFrame notIndexed

  methods

    function fr = notIndexedFrame(name,color)

      fr.name = 'notIndexed';
      fr.color = [NaN NaN NaN];
      if nargin >= 1, fr.name = name; end
      if nargin >= 2, fr.color = color; end

    end

  end

end
