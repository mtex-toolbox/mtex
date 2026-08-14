function R = fitFrame(R,fr)
% adjust an orientation to act on data expressed in the frame fr
%
% Rotating data with an orientation requires the data to be expressed in
% the frame the orientation acts on - the SYMMETRY of the data is
% irrelevant for this, only the frames have to fit (ADR 0003). A crystal
% frame never fits a specimen frame: rotating specimen framed data with
% an orientation that acts on crystal coordinates (or vice versa) is a
% wrong sided rotation and errors. Between two crystal frames, aligned
% ones pass unchanged, a compatible transition is absorbed into the
% returned rotation, incompatible ones error. Frame-free data passes
% unchecked, as it always has, and so do two specimen frames - their
% bases carry no meaning yet.
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

% frame-free data passes
if isempty(fr), return; end

frR = R.CS.frame;

% a crystal frame never fits a specimen frame
if isa(fr,'crystalFrame') ~= isa(frR,'crystalFrame')
  error('MTEX:orientation:frameMismatch',...
    ['The data is expressed in a %s while the orientation acts on a %s ' ...
    '- this looks like a rotation from the wrong side.'],class(fr),class(frR));
end

% two specimen frames pass; aligned crystal frames pass
if ~isa(fr,'crystalFrame') || isAligned(frR,fr), return; end

[fits,M] = isCompatible(fr,frR);

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
