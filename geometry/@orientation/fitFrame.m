function R = fitFrame(R,fr)
% adjust an orientation to act on data expressed in the frame fr
%
% Rotating data with an orientation requires the data to be expressed in
% the crystal frame the orientation acts on - the SYMMETRY of the data is
% irrelevant for this, only the frames have to fit (ADR 0003). Aligned
% frames pass unchanged; a compatible frame transition is absorbed into
% the returned rotation; incompatible frames error. Nothing is checked
% unless both frames are crystal frames - frame-free data and data in a
% specimen frame pass unchecked, as they always have.
%
% Syntax
%   R = fitFrame(R,fr)
%
% Input
%  R  - @orientation
%  fr - @referenceFrame the data is expressed in
%
% Output
%  R - @orientation, acting on data expressed in fr
%
% See also
% symmetry/ensureCS referenceFrame/isCompatible

if isempty(fr) || ~isa(fr,'crystalFrame') || ~isa(R.CS.frame,'crystalFrame') ...
    || isAligned(R.CS.frame,fr)
  return
end

[fits,M] = isCompatible(fr,R.CS.frame);

if fits
  disp(' ');
  disp('  The reference frame of the data differs from the crystal frame');
  disp('  of the orientation - transforming the rotation accordingly.');
  disp(' ');
  R = times(R,rotation.byMatrix(M),0);
else
  error('MTEX:orientation:frameMismatch',...
    ['The reference frame of the data does not fit the crystal frame ' ...
    'of the orientation.']);
end
