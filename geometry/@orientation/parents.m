function mori = parents(mori)
% variants of an orientation relationship
%
% Syntax
%   
%   ori_parents = ori_child * inv(mori.parents)
%
% Input
%  mori - child to parent @orientation relationship
%  ori_child - child orientation
%
% Output
%  ori_parents - all possible parent @orientation
%
% Example
%   % parent symmetry
%   cs_fcc = crystalSymmetry('m-3m', [3.6599 3.6599 3.6599], 'mineral', 'Iron fcc');
%
%   % child symmetry
%   cs_bcc = crystalSymmetry('m-3m', [2.866 2.866 2.866], 'mineral', 'Iron bcc')
%
%   % define a bcc child orientation
%   ori_bcc = orientation.goss(cs_bcc)
%
%   % define Nishiyama Wassermann fcc to bcc orientation relation ship
%   NW = orientation.NishiyamaWassermann (cs_fcc,cs_bcc)
%
%   % compute a fcc parent orientation related to the bcc child orientation
%   ori_fcc = ori_bcc * NW
%
%   % compute all symmetrically possible parent orientations
%   ori_fcc = unique(ori_bcc.symmetrise * NW)
%
%   % same using the function parents
%   ori_fcc2 = ori_bcc * NW.parents
%
% See also
% orientation/variants
%

% store child symmetry
CS_child = mori.SS;

% symmetrise only with respect to child symmetry
mori = CS_child * mori;

% ignore all variants symmetrically equivalent 
% with respect to the parent symmetry
mori.SS = crystalSymmetry('1');
mori = unique(mori);
mori.SS = CS_child;
