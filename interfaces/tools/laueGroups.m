function t = laueGroups
% the 11 Laue classes, in the order Channel numbers them, with the code TSL
% writes for each
%
% Syntax
%   t = laueGroups
%
% Output
%  t - 11 × 2 cell, {name, TSL code}, row k being Channel's Laue group k
%
% See also
% TSL2pointGroup loadEBSD_ctf exportEBSD_ctf

t = {'-1',1; '2/m',20; 'mmm',22; '4/m',4; '4/mmm',42; ...
  '-3',3; '-3m',32; '6/m',6; '6/mmm',62; 'm-3',23; 'm-3m',43};

end
