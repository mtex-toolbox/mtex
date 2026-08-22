function ori = byScreenAlignment(frA,frB)
% the orientation implied by two frames being aligned on screen
%
% Data in |frA| is drawn under |frA.how2plot| and data in |frB| under
% |frB.how2plot|. If the two were plotted and seen to coincide, that
% assertion pins the rotation between the frames: a point sitting at |v| in
% |frA| sits at |ori*v| in |frB|.
%
% This is an inference from a user assertion, not a geometric fact about the
% two bases. It reads |how2plot| and never touches |basis|, so it can be
% used to *establish* a basis - see <imageFrame.assumedFor.html
% |imageFrame.assumedFor|>. Once a basis has been set from it,
% <referenceFrame.transformationMatrix.html |transformationMatrix|>
% reproduces the same rotation from the bases alone, which is the invariant
% worth asserting in a test.
%
% Syntax
%
%   ori = orientation.byScreenAlignment(imgFrame,specimenFrame.default)
%
%   ori.frameRight   % frA, the source
%   ori.frameLeft    % frB, the target
%
% Input
%  frA - @referenceFrame, the source
%  frB - @referenceFrame, the target
%
% Output
%  ori - @orientation taking coordinates in frA to coordinates in frB
%
% Description
% A point at |v| renders at |inv(fr.how2plot.rot)*v| in screen coordinates.
% "Aligned on screen" is therefore
%
%   inv(frA.how2plot.rot) * vA == inv(frB.how2plot.rot) * vB
%
% which rearranges to |vB = frB.how2plot.rot * inv(frA.how2plot.rot) * vA|.
%
% See also
% imageFrame referenceFrame/transformationMatrix plottingConvention

argin_check(frA,'referenceFrame');
argin_check(frB,'referenceFrame');

% an empty convention means "follows the session default", which would make
% the result depend on session state - the very thing stating a frame
% relation explicitly is meant to remove
assert(~isempty(frA.how2plot) && ~isempty(frB.how2plot),...
  'MTEX:orientation:noConvention',...
  ['Both frames need a plotting convention of their own. An empty one '...
  'follows the session default, so the rotation inferred from it would '...
  'change when the session default changes.']);

rot = frB.how2plot.rot * inv(frA.how2plot.rot); %#ok<MINV>

% the frames of an orientation are the frames of its symmetries (ADR 0003),
% so each side is wrapped in the trivial group carrying it. CS is the source
% and SS the target, matching the convention that an orientation maps right
% to left
ori = orientation(rot, specimenSymmetry(frA), specimenSymmetry(frB));

end
