function out = symMismatch(m1,m2)
% whether two @Miller are too different to compare their directions
%
% What has to fit is the crystal frame the indices are expressed in, not
% the point group (ADR 0003, orientation without symmetry). A trivial group
% is an honest "no symmetry claim" - the unsymmetrised extremum of a GBND,
% say - and it symmetrises to itself, which is exactly the comparison the
% caller asked for. Two genuine groups that disagree still mean the data
% comes from different phases and are worth the warning.
%
% Syntax
%   out = symMismatch(m1,m2)
%
% Input
%  m1, m2 - @Miller
%
% Output
%  out - logical

cs1 = m1.CS; cs2 = m2.CS;

% frames that do not fit are a mismatch whatever the groups say
if ~isempty(cs1.frame) && ~isempty(cs2.frame) && ...
    ~(cs1.frame == cs2.frame || isAligned(cs1.frame,cs2.frame))
  out = true;
  return
end

% id 1 and 2 are the trivial groups, which claim nothing
out = cs1.id > 2 && cs2.id > 2 && cs1.Laue.id ~= cs2.Laue.id;

end
