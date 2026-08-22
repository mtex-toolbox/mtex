classdef spatialTransformComposite < spatialTransform
% several spatial transforms applied one after another
%
% What mtimes returns when two transforms cannot be absorbed into one. It
% is also how a hop fitted in several stages stays a single transform while
% keeping the stages available for inspection - a tilt is fitted as a
% projective, then a polynomial on the residual, but it is one distortion.
%
% Stages are held in the order they are applied, so stages(1) acts first.
% A composite given a composite flattens it, so a chain never nests.
%
% Syntax
%
%   T = spatialTransformComposite(T1,T2)   % apply T1, then T2 - i.e. T2*T1
%   T = spatialTransformComposite(TArray)
%
% Input
%  T1, T2 - @spatialTransform, in the order they are applied
%  TArray - @spatialTransform array, likewise
%
% Output
%  T - @spatialTransformComposite
%
% Class Properties
%  stages - @spatialTransform array, stages(1) applied first
%
% See also
% spatialTransform spatialTransform/mtimes

  properties
    stages = spatialTransformId.empty
  end

  methods

    function T = spatialTransformComposite(varargin)

      for k = 1:numel(varargin)

        s = varargin{k};

        assert(isa(s,'spatialTransform'),'MTEX:spatialTransform:badStage',...
          'A composite is built from spatial transforms, got %s.',class(s));

        % flatten, so a chain of products stays one level deep
        for j = 1:length(s)
          if isa(s(j),'spatialTransformComposite')
            T.stages = [T.stages, s(j).stages];
          else
            T.stages = [T.stages, s(j)];
          end
        end

      end

    end

    function pos = eval(T,pos)

      for k = 1:length(T.stages), pos = eval(T.stages(k),pos); end

    end

    function T = inv(T)

      s = T.stages;
      for k = 1:length(s), s(k) = inv(s(k)); end
      T.stages = fliplr(s);

    end

    function tf = isid(T)
      tf = all(arrayfun(@isid,T.stages));
    end

    function s = char(T)

      if isempty(T.stages), s = 'composite  (empty)'; return; end

      names = arrayfun(@(t) string(char(t)),T.stages);
      s = char("composite  " + join(names," -> "));

    end

  end

end
