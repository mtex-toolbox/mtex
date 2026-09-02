function name = foldAlignment(name)
% a point group name without the axis alignment MTEX adds to it
%
% MTEX keeps the alignment of a group with the crystal axes - 12/m1 and 112/m
% are both 2/m to a file format that numbers the 32 point groups, and the
% lattice angles written next to it are what tells them apart on import.
%
% Syntax
%   name = foldAlignment('-3m1')   % '-3m'
%
% See also
% TSL2pointGroup exportEBSD_ctf

name = char(name);

folded = { ...
  '211','2'; 'm11','m'; '2/m11','2/m'; ...
  '121','2'; '1m1','m'; '12/m1','2/m'; ...
  '112','2'; '11m','m'; '112/m','2/m'; ...
  '2mm','mm2'; 'm2m','mm2'; ...
  '321','32'; '312','32'; '3m1','3m'; '31m','3m'; '-3m1','-3m'; '-31m','-3m'; ...
  '-4m2','-42m'; '-6m2','-62m'};

i = find(strcmp(folded(:,1),name),1);
if ~isempty(i), name = folded{i,2}; end

end
