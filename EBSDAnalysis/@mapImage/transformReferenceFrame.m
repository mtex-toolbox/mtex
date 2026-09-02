function mg = transformReferenceFrame(mg,target,varargin)
% state which frame a sequence of images is in, and lay them out that way
%
% Where a raster array sits relative to a specimen is not derivable from the
% array, so two images are not comparable until they are stated in one frame.
% This is the step that states it. It is deliberately explicit: the relation
% is a fact about the experiment that only the person who ran it knows, and
% guessing it silently is how a mirrored map reaches the end of a workflow
% and returns nonsense.
%
% Syntax
%
%   mg = transformReferenceFrame(mg,gL)                 % a layout
%   mg = transformReferenceFrame(mg,other)              % that of another image
%   mg = transformReferenceFrame(mg,fr,ori)             % the rotation, known
%   mg = transformReferenceFrame(mg,fr,'byScreenAlignment')
%
% Input
%  mg     - @mapImage, one or an array
%  gL     - @gridLayout to lay the array out in
%  other  - @mapImage, meaning its layout
%  fr     - @referenceFrame every entry is to end up in
%  ori    - @orientation from an entry's frame to fr, when it is known
%
% Output
%  mg - the same images, laid out in the target
%
% Description
% The relation may be given three ways, most certain first:
%
%   ori                  the rotation, when it is known outright
%   'byScreenAlignment'  inferred from the assertion that the frames were
%                        plotted together and seen the same way up
%   neither              read off the two bases, when both already carry one
%
% Like <Miller.transformReferenceFrame.html the method of the same name on
% @Miller> this changes the numbers, not the thing: nothing is resampled and
% no value changes, only the layout and the frame stamp. Only a signed
% permutation can be applied by reindexing, so a relation that is not axis
% aligned raises rather than silently resampling.
%
% A map travelling with an image is turned with it, so the two stay in one
% array order and ebsd.bc can sit beside img without a conversion.
%
% See also
% mapImage gridLayout orientation/byScreenAlignment
% EBSDsquare/transformReferenceFrame

if isa(target,'mapImage'), target = target.layout; end

argin_check(target,'referenceFrame');

ori = getClass(varargin,'orientation',[]);
byPlot = check_option(varargin,'byScreenAlignment');

% the array order the target stands for. A specimen frame does not state one
% on its own, so read it the way an entry carrying a map is read
isLayout = isa(target,'gridLayout');
if isLayout
  tgt = target;
else
  tgt = gridLayout.assumedFor(target);
end

% a layout says nothing about the specimen, so asking for one is a
% reindexing and nothing else - there is no relation to state
assert(~isLayout || (isempty(ori) && ~byPlot),'MTEX:mapImage:layoutRelation',...
  ['A @gridLayout only says which way round the array is stored. Give a '...
  '@referenceFrame as the target to state where the images sit.']);

for n = 1:numel(mg)

  b = mg(n).layout.basis;

  % b holds the array's own axes. Where the entry's frame is already stated
  % in the same space as the target no rotation enters; a frame that is
  % still unrelated carries a placeholder basis, and the relation given here
  % is what turns it into a statement
  R = eye(3);
  if ~isempty(ori)
    R = matrix(ori);
  elseif byPlot
    % the assertion is "these all look the same way up on screen", so what it
    % relates is the convention each entry is DRAWN in - its own frame -
    % against the target's. Not the layouts: those are being solved for
    drawnIn = mg(n).frame;
    if isempty(drawnIn), drawnIn = ownFrame; end
    R = matrix(orientation.byScreenAlignment(drawnIn,target));
  end

  b = turned(b,R);

  % dimension 1 first, as layoutIndex takes its source
  src = b(1:2);

  posOld = mg(n).pos;

  linImg = layoutIndex(tgt,src,size(mg(n).img));
  [linPos,doTranspose] = layoutIndex(tgt,src,size(posOld));

  mg(n).img = mg(n).img(linImg);
  posNew = posOld(linPos);

  if ~isempty(mg(n).ebsd)
    mg(n).ebsd = transformReferenceFrame(mg(n).ebsd,tgt);
  end

  % the target defines the new directions outright - row along basis(1) and
  % column along basis(2) - so only the step lengths carry over, exchanged
  % if the array transposed
  step = [norm(mg(n).d1), norm(mg(n).d2)];
  if doTranspose, step = flip(step); end

  mg(n).d1 = step(1) * tgt.basis(1);
  mg(n).d2 = step(2) * tgt.basis(2);

  % whichever corner the flips brought to the front, carried into the frame
  % the entry is now stated in
  mg(n).origin = turned(posNew(1,1),R);

  % only a frame target restates where the entry sits - a layout leaves it
  % where it was and merely reorders the array
  if ~isLayout, mg(n).frame = target; end

end

end

% -------------------------------------------------------------------------
function v = turned(v,R)
% the vectors rotated by the matrix R, shape kept

xyz = R * [v.x(:).'; v.y(:).'; v.z(:).'];
v = reshape(vector3d(xyz(1,:),xyz(2,:),xyz(3,:)),size(v));

end
