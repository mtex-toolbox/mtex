function [lin,doTranspose] = layoutIndex(iF,dims,sz,varargin)
% the reindexing that lays an array out in this image frame
%
% Syntax
%
%   lin = layoutIndex(iF,[d1 d2],size(A))
%   lin = layoutIndex(iF,src,size(A))
%   lin = layoutIndex(iF,src,size(A),'nearest')
%   [lin,doTranspose] = layoutIndex(iF,[d1 d2],size(A))
%
% Input
%  iF   - @imageFrame the array is to be laid out in, i.e. the TARGET
%  dims - 1x2 @vector3d, the directions dimensions 1 and 2 advance along
%  src  - @imageFrame, the same stated as a frame
%  sz   - size(A), dimensions beyond the first two are left alone
%
% Output
%  lin         - linear indices, A(lin) is A laid out in iF
%  doTranspose - whether the first two dimensions were exchanged
%
% Flags
%  nearest - snap to the closest layout instead of erroring
%
% Description
% An image frame says which specimen directions the row and the column index
% of an array advance along, so two of them differ by a transpose and two
% flips - a signed permutation, the only thing reindexing can express. The
% inverse is the same call with the two layouts swapped.
%
% The source is given as two directions rather than a frame because a grid
% may be sheared, and an @imageFrame requires its axes perpendicular.
%
% doTranspose is reported because a transpose also exchanges whatever is
% indexed BY dimension - a pixel step, a size - which the index cannot carry.
%
% See also
% imageFrame referenceFrame/transformationMatrix EBSDsquare/transformReferenceFrame

% a frame states the same thing: row along basis(2), column along basis(1)
if isa(dims,'referenceFrame'), dims = [dims.basis(2), dims.basis(1)]; end

d = normalize(reshape(dims,1,2));
t = normalize(iF.basis(1:2));

if any(isnan(d.x)) || any(isnan(d.y))
  error('MTEX:imageFrame:degenerateLayout',...
    'A layout needs two directions of nonzero length.');
end

% direction cosines of the array's own axes against the two the matrix
% dimensions have to follow - row is dimension 1, column is dimension 2
Q = [dot(t(2),d(1)) dot(t(2),d(2)); ...
     dot(t(1),d(1)) dot(t(1),d(2))];

% Q is orthogonal, so the larger diagonal is the nearer signed permutation
off = abs(Q(1,2)) + abs(Q(2,1));
dia = abs(Q(1,1)) + abs(Q(2,2));

if abs(off - dia) > 1e-12
  doTranspose = off > dia;
else
  % a grid at 45 degrees aligns equally well either way, so nothing about it
  % can decide - let the target say instead, keeping a transposed layout the
  % transpose of the layout it is the transpose of
  doTranspose = abs(dot(t(1),yvector)) > abs(dot(t(1),xvector));
end

if ~check_option(varargin,'nearest')
  onAxis = abs(Q) > 1 - 1e-6;
  if nnz(onAxis) ~= 2 || ~all(any(onAxis,1)) || ~all(any(onAxis,2))
    error('MTEX:imageFrame:notAxisAligned','%s\n\n  %s\n  %s\n\n%s\n\n  %s',...
      ['An array can be laid out differently only by reindexing it, so the '...
      'layout it is in and the one asked for have to differ by a transpose '...
      'and two flips. These do not:'],...
      ['is         dim 1 along ' char(d(1)) ', dim 2 along ' char(d(2))],...
      ['asked for    row along ' char(t(2)) ', col along ' char(t(1))],...
      ['Anything else needs resampling. To take the closest layout a '...
      'permutation can reach instead - which is what a gridded map does - pass'],...
      'layoutIndex(...,''nearest'')');
  end
end

if doTranspose, Q = Q(:,[2 1]); end

lin = reshape(1:prod(sz),[sz 1]);
if doTranspose, lin = permute(lin,[2 1 3:numel(sz)]); end
if Q(1,1) < 0, lin = flip(lin,1); end
if Q(2,2) < 0, lin = flip(lin,2); end

end
