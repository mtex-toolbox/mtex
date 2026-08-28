function ok = symFits(s1,s2,level)
% whether two symmetries are the same, at the leniency the caller needs
%
% Three questions are asked across the toolbox and they differ in more than a
% tolerance - in which group identity is compared, in how an absent frame is
% read, and in whether a trivial group counts. The leniency picks one of the
% three combinations that are actually meaningful rather than exposing those
% axes separately.
%
% |'strict'| - the same group in the identical frame. An equal-valued fork is
% a different symmetry, so the frame is compared by handle, and a frame that
% is absent decides nothing and therefore fails. This is what an @SO3VectorField
% asks of the symmetry its inner function carries.
%
% |'same'| - the same group in the same frame. On a crystal side the frame
% handle alone would already decide, since every @crystalSymmetry mints its own
% frame and |stripSym| keeps it; but on the specimen side every group shares the
% session frame, so the group is compared always - by Laue id, never by handle
% (ADR 0003). Two minerals may share a Laue class and a lattice and still be
% different phases, so a name that is given on both sides has to agree.
%
% |'compatible'| - enough to compare two directions. A trivial group is an
% honest "no symmetry claim" - the unsymmetrised extremum of a GBND, say - and
% it symmetrises to itself, which is exactly the comparison the caller asked
% for. Two genuine groups that disagree mean the data comes from different
% phases.
%
% Open: the mineral name is compared at |'same'| and not at |'compatible'|,
% which is where each of the two predicates this replaces stood. Making it
% uniform would change what @Miller/dot warns about and is a decision about
% phase identity, not a consolidation.
%
% Syntax
%   ok = symFits(s1,s2)
%   ok = symFits(s1,s2,'strict')
%
% Input
%  s1, s2 - @symmetry
%  level  - 'strict', 'same' (default) or 'compatible'
%
% Output
%  ok - logical
%
% See also
% framesFit symmetry/eqTol crystalSymmetry/eqLazy phaseItem/sim

if nargin < 3, level = 'same'; end

switch lower(level)

  case 'strict'

    ok = s1 == s2 || (s1.id == s2.id && framesFit(s1,s2) && ...
      strcmp(class(s1),class(s2)));

  case 'same'

    ok = s1.Laue.id == s2.Laue.id && sameMineral(s1,s2) && ...
      framesFit(s1,s2);

  case 'compatible'

    % id 1 and 2 are the trivial groups, which claim nothing
    ok = framesFit(s1,s2) && ...
      (s1.id <= 2 || s2.id <= 2 || s1.Laue.id == s2.Laue.id);

  otherwise

    error('MTEX:symFits:unknownLevel',...
      ['The leniency has to be ''strict'', ''same'' or ''compatible'', ' ...
      'not ''' char(level) '''.']);

end

end

function ok = sameMineral(s1,s2)
% a name only decides when both sides carry one
ok = ~(isa(s1,'crystalFrame') && isa(s2,'crystalFrame') && ...
  ~isempty(s1.mineral) && ~isempty(s2.mineral) && ...
  ~strcmpi(s1.mineral,s2.mineral));
end
