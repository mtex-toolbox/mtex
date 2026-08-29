function out = inGroup(R,fr)
% whether every rotation given is an element of the group a frame carries
%
% Rotating a tensor by an element of its own group leaves it where it was,
% which is what symmetrise and checkSymmetry do; by anything else it stops
% being invariant under that group, and the frame must not claim it still
% is.
%
% A long list is never asked: a caller rotating a tensor into the
% orientations of a map is not rotating by symmetry elements, and the test
% would cost numSym comparisons per entry.

out = false;

if ~isa(R,'rotation') || isempty(fr) || fr.id == 1, return; end

% rotating by nothing takes nothing out of the group
if isempty(R), out = true; return; end

s = fr.rot;
if length(R) > length(s), return; end

R = R(:); s = s(:).';

% the improper flag has to agree as well - dot compares the quaternion only
out = all(any(abs(dot_outer(R,s)) > cos(5e-4) & (R.i == s.i), 2));

end
