function mori = variants(mori)
%
%
% Example
%   % define fcc and bcc symmetry
%   cs_fcc = crystalSymmetry('m-3m', [3.6599 3.6599 3.6599], 'mineral', 'Iron fcc');
%   cs_bcc = crystalSymmetry('m-3m', [2.866 2.866 2.866], 'mineral', 'Iron bcc')
%
%   % define a fcc parent orientation
%   ori_fcc = orientation.brass(cs_fcc)
%
%   % define Kurdjumov Sachs fcc to bcc orientation relation ship
%   fcc2bcc = orientation.KurdjumovSachs(cs_fcc,cs_bcc)
%   fcc2bcc = orientation.NishiyamaWassermann(cs_fcc,cs_bcc)
%   fcc2bcc = orientation.Bain(cs_fcc,cs_bcc)
%
%   % compute one bcc orientation related to the fcc orientation
%   ori_bcc = ori_fcc * fcc2bcc
%
%   % compute all symmetrically possible child orientations
%   ori_bcc = unique(ori_fcc.symmetrise * fcc2bcc)
%
%   % same result use the function variants
%   ori_bcc2 = ori_fcc * fcc2bcc.Variants
%
%   % we may also compute possible child to child misorientations
%   bcc2bcc = unique(variants(fcc2bcc) * variants(inv(fcc2bcc)))
%
% Input
%
% Output
%
%

% store parent and child symmetry
CS_child = mori.SS;

% symmetrise only with respect to child symmetry
mori = CS_child * mori;

% ignore all variants symmetrically equivalent 
% with respect to the child symmetry
mori.SS = crystalSymmetry('1');
mori = unique(mori);
mori.SS = CS_child;
