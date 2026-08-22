function mg = transformReferenceFrame(mg,iF)
% lay a mapImage out in another image frame
%
% Two images are comparable pixel by pixel only once their arrays are laid
% out the same way. This turns one to face the other - a transpose and two
% flips at most, nothing resampled and no value changed.
%
% The map that travels with the image is turned with it, so ebsd.bc keeps
% sitting beside img pixel for pixel.
%
% Syntax
%
%   mg = transformReferenceFrame(mg,iF)
%   mg = transformReferenceFrame(mg,other)
%
% Input
%  mg    - @mapImage
%  iF    - @imageFrame to lay the array out in
%  other - @mapImage, meaning its arrayFrame
%
% Output
%  mg - @mapImage
%
% See also
% mapImage imageFrame/layoutIndex EBSDsquare/transformReferenceFrame

if isa(iF,'mapImage'), iF = iF.arrayFrame; end

argin_check(iF,'imageFrame');

src = [mg.d1,mg.d2];

% the positions, before origin and the steps are restated in the new layout
posOld = mg.pos;

linImg = layoutIndex(iF,src,size(mg.img));
linPos = layoutIndex(iF,src,size(posOld));

mg.img = mg.img(linImg);
posNew = posOld(linPos);

if ~isempty(mg.ebsd), mg.ebsd = transformReferenceFrame(mg.ebsd,iF); end

% the target frame defines the new directions outright - the row index
% advances along basis(2) and the column index along basis(1) - so only the
% step lengths have to be carried over, exchanged if the array transposed
[~,doTranspose] = layoutIndex(iF,src,size(mg.img));
step = [norm(mg.d1), norm(mg.d2)];
if doTranspose, step = flip(step); end

mg.d1 = step(1) * iF.basis(2);
mg.d2 = step(2) * iF.basis(1);

% whichever corner the flips brought to the front is the new origin, read
% off the permuted positions rather than worked out from the flips
mg.origin = posNew(1,1);

end
