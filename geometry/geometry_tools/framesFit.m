function ok = framesFit(fr1,fr2)
% whether two reference frames may be treated as one
%
% Never across kinds: a symmetry built without lattice parameters has the
% canonical basis, so the alignment test alone would accept a crystal frame
% against a specimen one. A frame-free object states nothing and fits
% anything - that is how legacy data keeps working.
%
% This is the frame half of the question <symFits.html |symFits|> asks; the
% group half is what the leniency there selects. Not to be confused with
% <orientation.fitFrame.html |fitFrame|>, which adjusts an orientation rather
% than answering a question about two frames.
%
% Syntax
%   ok = framesFit(fr1,fr2)
%
% Input
%  fr1, fr2 - @referenceFrame, either may be empty
%
% Output
%  ok - logical
%
% See also
% symFits referenceFrame/isAligned orientation/fitFrame

if isempty(fr1) || isempty(fr2), ok = true; return; end

if isa(fr1,'crystalFrame') ~= isa(fr2,'crystalFrame'), ok = false; return; end

ok = fr1 == fr2 || isAligned(fr1,fr2);

end
