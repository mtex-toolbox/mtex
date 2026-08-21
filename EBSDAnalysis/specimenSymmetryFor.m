function ss = specimenSymmetryFor(pC)
% the specimen symmetry to hand to an orientation for a plotting convention
%
% Description
% An orientation keeps its plotting convention in its specimen symmetry.
% Writing it there after the fact - ori.SS.how2plot = pC - is not an option:
% @symmetry is a handle class and @orientation initialises SS with the very
% instance returned by specimenSymmetry.default, so such an assignment does
% not attach the convention to this orientation at all.
%
% The default instance is therefore reused only while it already carries
% this convention, and a private specimen symmetry is created otherwise.
% Both are triclinic, and @symmetry/eq compares point group ids next to
% handle identity, so ss == specimenSymmetry.default either way.
%
% Input
%  pC - @plottingConvention, or the @referenceFrame the data lives in
%
% Output
%  ss - @specimenSymmetry
%
% See also
% EBSD/subsref grain2d/subsref plottingConvention/matchDefault

ss = specimenSymmetry.default;

% a data class that knows its frame passes the frame itself, and it is adopted
if isa(pC,'referenceFrame')
  if ss.frame ~= pC
    ss = copy(ss);
    ss.frame = pC;
  end
  return
end

% == is equal alignment, so reuse the default symmetry for the default plotting
if isempty(pC) || ss.how2plot == pC, return; end

ss = specimenSymmetry(pC);

end
