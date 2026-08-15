function [a,left,right] = ensureSym(a,b)
% ensure the inner reference frames of a and b are compatible
%
% What has to fit between the two factors is the reference frame the inner
% coordinates are expressed in - NOT the symmetry groups: aligned crystal
% frames pass also when the point groups differ (ADR 0003, orientation
% without symmetry). Group checks remain only for bare rotation factors,
% which have to respect the symmetry they are multiplied onto.

% collect inner and outer symmetries
[left,inner1] = extractSym(a);
[inner2,right] = extractSym(b);

if isempty(inner1)  % e.g. rot * ori

  if ~isempty(inner2) && inner2.id > 2 && ...
      ~(isa(a,'rotation') && all(max(dot_outer(inner2.rot,a))>0.99))
    warning('Rotation does not respect symmetry!');
  end
  left = inner2;

elseif isempty(inner2) % e.g. ori * rot, ori * vector3d

  if isa(b,'rotation')

    if inner1.id > 2 && ~all(max(dot_outer(inner1.rot,b))>0.99)
      warning('Rotation does not respect symmetry!');
    end

  elseif isa(inner1.frame,'crystalFrame') && isempty(frameOf(b))

    % framed data is gated by fitFrame inside rotate - only frame-free
    % data cannot be checked there
    warning('Possibly applying an orientation to an object in specimen coordinates!');

  end
  right = inner1;

elseif isa(b,'quaternion') && isa(a,'orientation')
  % ori * ori: the frames have to fit - aligned frames pass, a compatible
  % transition is absorbed into a, a wrong sided or incompatible
  % combination errors. For non-quaternion b (Miller, tensor, ...) the
  % fitFrame gate inside rotate takes over - transforming here as well
  % would transform twice.

  fr1 = inner1.frame; fr2 = inner2.frame;
  if ~(~isempty(fr1) && ~isempty(fr2) && fr1 == fr2) % same handle passes cheaply
    a = fitFrame(a,fr2);
  end

end

end

function fr = frameOf(obj)
% the reference frame of a factor that carries one, [] otherwise

try
  fr = obj.frame;
catch
  fr = [];
end

end
