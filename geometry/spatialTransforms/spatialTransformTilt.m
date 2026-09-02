classdef spatialTransformTilt < spatialTransformComposite
% specimen tilt, fitted in stages against a re-measured residual
%
% A tilt is a projective distortion, but one pass of correlation cannot
% resolve it: how well two tiles match depends on how well they already
% overlap, so a large distortion has to be taken out before the structure
% underneath it becomes visible. The projective stage removes the bulk,
% the correlation is run again, and a polynomial takes what is left.
%
% The class owns WHAT its stages are. It does not own the loop -
% re-measuring means going back to the images, and geometry must not
% depend on registration code. The caller drives:
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
% spatialTransformComposite spatialTransformProjective spatialTransformPoly

  methods

    function T = spatialTransformTilt(varargin)

      if nargin == 0
        varargin = {[spatialTransformProjective, ...
          spatialTransformPoly(zeros(3,2),1), spatialTransformPoly(zeros(6,2),2)]};
      end

      T = T@spatialTransformComposite(varargin{:});

    end

    function T = inv(T)
      % the stages reversed are no longer a tilt
      T = inv(spatialTransformComposite(T.stages));
    end

    function s = shortChar(~)
      s = 'tilt';
    end

  end

end
