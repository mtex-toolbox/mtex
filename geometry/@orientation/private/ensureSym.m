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

  % a rotation on the left acts in the specimen frame, so the group goes and the frame stays
  left = inner2;
  if isa(a,'rotation') && ~isempty(inner2)
    left = dropSymmetry(inner2,a,'specimen','orientation');
  end

elseif isempty(inner2) % e.g. ori * rot, ori * vector3d

  if isa(b,'rotation')

    % on the RIGHT it acts in the crystal frame
    inner1 = dropSymmetry(inner1,b,'crystal','orientation');

  elseif isa(inner1.frame,'crystalFrame') && isempty(frameOf(b))

    % framed data is gated by fitFrame inside rotate - only frame-free
    % data cannot be checked there
    warning('Possibly applying an orientation to an object in specimen coordinates!');

  end
  right = inner1;

elseif isa(b,'quaternion') && isa(a,'orientation')
  % ori * ori: the frames have to fit - for a non-quaternion b the gate inside rotate takes over

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
