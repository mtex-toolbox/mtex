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

% a data class that knows its frame passes the frame itself - the
% symmetry adopts the very handle, so the orientations keep following
% that frame, not a snapshot of its convention
if isa(pC,'referenceFrame')
  if ss.frame ~= pC
    ss = copy(ss);
    ss.frame = pC;
  end
  return
end

% plottingConvention is a value class, so == means equal alignment: the
% default symmetry is reused whenever the data is plotted the default
% way - what keeps both following the session default is the shared
% specimenFrame.default, not a shared convention handle
if isempty(pC) || ss.how2plot == pC, return; end

ss = specimenSymmetry(pC);

end
