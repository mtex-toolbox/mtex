classdef spatialTransformTilt < spatialTransform
% specimen tilt, fitted in stages against a re-measured residual
%
% A tilt is a projective distortion, but one pass of correlation cannot
% resolve it: how well two tiles match depends on how well they already
% overlap, so a large distortion has to be taken out before the structure
% underneath it becomes visible. The projective stage removes the bulk,
% the correlation is run again, and a polynomial takes what is left.
%
% The class owns WHAT its stages are and how each is fitted. It does not
% own the loop - re-measuring means going back to the images, and geometry
% must not depend on registration code. The caller drives:
%
%   T = spatialTransformTilt;
%   for s = 1:numel(T.stages)
%     [u,peak,pos] = xcfShift(imRef,imTest);
%     T = fitStage(T,s,pos,pos+u,'weights',peak);
%     imTest = interp(map,eval(inv(T),targetPos));
%   end
%
% An unfitted stage is the identity, so a partly fitted tilt evaluates as
% far as it has got.
%
% Syntax
%
%   T = spatialTransformTilt
%   T = fitStage(T,s,posA,posB,'weights',w)
%
% Input
%  s          - which stage to fit
%  posA, posB - @vector3d, the residual measured after the previous stages
%
% Output
%  T - @spatialTransformTilt
%
% Class Properties
%  stages - @spatialTransform array, stages(1) applied first
%
% See also
% spatialTransform spatialTransformProjective spatialTransformPoly

  properties
    stages = spatialTransform.empty
  end

  methods

    function T = spatialTransformTilt(stages)

      if nargin >= 1
        T.stages = stages;
      else
        T.stages = [spatialTransformProjective, ...
                    spatialTransformPoly(zeros(3,2),1), ...
                    spatialTransformPoly(zeros(6,2),2)];
      end

    end

    function T = fitStage(T,s,posA,posB,varargin)
      % fit stage s to the residual left by the stages before it

      assert(s >= 1 && s <= length(T.stages),'MTEX:spatialTransform:badStage',...
        'This transform has %d stages, asked for %d.',length(T.stages),s);

      switch class(T.stages(s))
        case 'spatialTransformProjective'
          T.stages(s) = spatialTransformProjective.fit(posA,posB,varargin{:});
        case 'spatialTransformPoly'
          T.stages(s) = spatialTransformPoly.fit(posA,posB,...
            'degree',T.stages(s).degree,varargin{:});
        otherwise
          error('MTEX:spatialTransform:badStage',...
            'Stage %d is a %s, which has no fit.',s,class(T.stages(s)));
      end

    end

    function pos = eval(T,pos)

      for k = 1:length(T.stages), pos = eval(T.stages(k),pos); end

    end

    function T = inv(T)

      s = T.stages;
      for k = 1:length(s), s(k) = inv(s(k)); end
      T = spatialTransformComposite(fliplr(s));

    end

    function tf = isid(T)
      tf = all(arrayfun(@isid,T.stages));
    end

    function s = shortChar(~)
      s = 'tilt';
    end

    function s = paramChar(T)

      names = arrayfun(@(t) string(char(t)),T.stages);
      s = char(join(names," -> "));

    end

    function s = char(T)
      s = ['tilt  ' paramChar(T)];
    end

    function stages = stageList(T)
      stages = T.stages;
    end

  end

end
