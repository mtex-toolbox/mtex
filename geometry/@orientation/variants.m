function mori = variants(mori)
% variants of an orientation relationship
%
% Syntax
%   
%   ori_variants = ori_parent * mori.variants
%
% Input
%
%  mori - child to parent @orientation relationship
%  ori_parent - parent @orientation
%
% Output
%
%  ori_variants - all possible child @orientation
%
% Example
%   % parent symmetry
%   cs_fcc = crystalSymmetry('432', [3.6599 3.6599 3.6599], 'mineral', 'Iron fcc');
%
%   % child symmetry
%   cs_bcc = crystalSymmetry('432', [2.866 2.866 2.866], 'mineral', 'Iron bcc')
%
%   % define a fcc parent orientation
%   ori_fcc = orientation.brass(cs_fcc)
%
%   % define Nishiyama Wassermann fcc to bcc orientation relation ship
%   NW = orientation.NishiyamaWassermann(cs_fcc,cs_bcc)
%
%   % compute a bcc child orientation related to the fcc orientation
%   ori_bcc = ori_fcc * inv(NW)
%
%   % compute all symmetrically possible child orientations
%   ori_bcc = unique(ori_fcc.symmetrise * inv(NW))
%
%   % same using the function variants
%   ori_bcc2 = ori_fcc * inv(NW.variants)
%
%   % we may also compute all possible child to child misorientations
%   bcc2bcc = unique(NW.variants * inv(NW))
%
% See also
% orientation/parents

% store parent
CS_parent = mori.CS;

% symmetrise only with respect to parent symmetry
mori = mori * CS_parent;

% ignore all variants symmetrically equivalent with respect to the child
% symmetry
mori.CS = crystalSymmetry('1');
mori = unique(mori);
mori.CS = CS_parent;
