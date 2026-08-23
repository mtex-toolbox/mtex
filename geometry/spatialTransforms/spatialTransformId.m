classdef spatialTransformId < spatialTransform
% the transform that leaves every position where it is
%
% Composing with it is a no-op on either side, so a hop where nothing
% separates the two frames needs no special case at the call sites.
%
% Syntax
%
%   T = spatialTransformId
%
% Output
%  T - @spatialTransformId
%
% See also
% spatialTransform

  methods

    function pos = eval(~,pos) %#ok<*INUSD>
    end

    function T = inv(T)
    end

    function tf = isid(~)
      tf = true;
    end

    function s = shortChar(~)
      s = 'identity';
    end

    function s = paramChar(~)
      s = '·';
    end

    function s = char(~)
      s = 'identity';
    end

    function stages = stageList(~)
      % nothing separates the two frames, so there is nothing to fit
      stages = spatialTransform.empty;
    end

  end

end
