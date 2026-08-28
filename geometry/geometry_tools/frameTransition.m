function ori = frameTransition(frFrom,frTo,varargin)
% the rotation that takes data from one reference frame into another
%
% The relation may be given three ways, most certain first:
%
%   ori                  the rotation, when it is known outright
%   'byScreenAlignment'  inferred from the assertion that the frames were
%                        plotted together and seen the same way up
%   neither              read off the two bases, which is what a frame
%                        already carrying one states
%
% This is the seam every |transformReferenceFrame| goes through, so the
% three ways mean the same thing whatever is being moved - a direction, an
% orientation, a tensor, a function on SO(3) or a raster of images.
%
% Syntax
%
%   ori = frameTransition(fr1,fr2)
%   ori = frameTransition(fr1,fr2,ori)
%   ori = frameTransition(fr1,fr2,'byScreenAlignment')
%   ori = frameTransition(fr1,fr2,'tolerance',1e-2)
%
% Input
%  fr1, fr2 - @referenceFrame, the source and the target
%  ori      - @orientation from fr1 to fr2, when it is known
%
% Options
%  tolerance - how far from a rotation reading the bases may come out
%
% Output
%  ori - @orientation taking coordinates in fr1 to coordinates in fr2
%
% See also
% orientation/align orientation/byScreenAlignment
% vector3d/transformReferenceFrame mapImage/transformReferenceFrame

ori = getClass(varargin,'orientation',[]);
if ~isempty(ori), return; end

if check_option(varargin,'byScreenAlignment')
  ori = orientation.byScreenAlignment(frFrom,frTo);
else
  ori = orientation.align(frFrom,frTo,varargin{:});
end

end
