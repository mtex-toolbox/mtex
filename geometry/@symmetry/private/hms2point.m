function s = hms2point(s)
% convert Herman – Mauguin (International) Symbol to point group
%
% Input
%  s - Herman – Mauguin (International) space group symbol
%
% Output
%  s - international point group symbol
%
% See also
%

% ignore first letter
assert(any(strcmp(s(1),{'A','B','C','F','I','P','R'})));
s = s(2:end);

% convert all planes to mirror planes
rep = {'a','b','c','d','n'};
for i = 1:length(rep)
  s = strrep(s,rep{i},'m');
end

% remove two consecutive numbers if the second is a divisor of the first
% eg. 63 62 42 32
if length(regexp(s,'[\dm]'))>=4
  ind = regexp(s,'\d\d');
  if ~isempty(ind)
    ind = ind(1);
    n1 = str2num(s(ind)); %#ok<ST2NM>
    n2 = str2num(s(ind+1)); %#ok<ST2NM>
    if n1 > n2, s(ind+1) = [];end
  end
end

% ignore 1
if ~isempty(regexp(s,'[m2-6]')), s = strrep(s,'1','');end

% clear all spaces
s = strrep(s,' ','');

% remove all upcase letter
ind = s==upper(s) & s~=lower(s);
s(ind) = [];

s= regexprep(s,'[:.]','');  % occurs sometimes

if isempty(s), s = '1';end
