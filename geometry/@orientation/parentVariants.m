function mori = parentVariants(mori)
%
%
% Example
%   % define fcc and bcc symmetry
%   cs_fcc = crystalSymmetry('m-3m', [3.6599 3.6599 3.6599], 'mineral', 'Iron fcc');
%   cs_bcc = crystalSymmetry('m-3m', [2.866 2.866 2.866], 'mineral', 'Iron bcc')
%
%   % define a bcc child orientation
%   ori_bcc = orientation.brass(cs_bcc)
%
%   % define Kurdjumov Sachs fcc to bcc orientation relation ship
%   fcc2bcc = orientation.NishiyamaWassermann(cs_fcc,cs_bcc)
%   fcc2bcc = orientation.Bain(cs_fcc,cs_bcc)
%
%   % compute one fcc orientation related to the fcc orientation
%   ori_fcc = ori_fcc * inv(fcc2bcc)
%
%   % compute all symmetrically possible child orientations
%   ori_bcc = unique(ori_fcc.symmetrise * fcc2bcc)
%
%   % same result use the function variants
%   ori_bcc = ori_fcc * fcc2bcc.variants
%
% Input
%
% Output
%
%

% store parent and child symmetry
CS_parent = mori.CS;

% symmetrise only with respect to parent symmetry
mori = mori * mori.CS;

% ignore all variants symmetrically equivalent 
% with respect to the child symmetry
mori.CS = crystalSymmetry('1');
mori = unique(mori);
mori.CS = CS_parent;
