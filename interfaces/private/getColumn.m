function [v,notes] = getColumn(ebsd,aliases,default,name,notes)
% one data column of a text file, by any of the names it may go under
%
% Description
%
% Which property holds e.g. the image quality depends on where the data
% came from: an .ang calls it iq, a .ctf calls the comparable quantity bc,
% and an HDF5 file may spell it IQ or RadonQuality. The first alias is the
% column's own name, the ones after it are substitutes - taking one is
% worth saying, so it is recorded in notes rather than warned about
% column by column.
%
% Syntax
%   [v,notes] = getColumn(ebsd,{'iq','bc'},0,'IQ',notes)
%
% Input
%  ebsd    - @EBSD
%  aliases - cell array of property names, own name first
%  default - value to fill the column with when none of them is there
%  name    - the column's name in the file, for the note
%  notes   - cell array of notes so far
%
% Output
%  v     - the column, shaped like ebsd
%  notes - notes, extended by what this column was filled from

if nargin < 5, notes = {}; end

fn = fieldnames(ebsd.prop);

for i = 1:numel(aliases)

  j = find(strcmpi(fn,aliases{i}),1);
  if isempty(j), continue; end

  p = ebsd.prop.(fn{j});
  if islogical(p), p = double(p); end
  if ~isnumeric(p) || numel(p) ~= numel(ebsd), continue; end

  v = double(p);
  if i > 1
    notes{end+1} = sprintf('%s taken from ''%s''',name,fn{j}); %#ok<AGROW>
  end
  return

end

v = default * ones(size(ebsd));
notes{end+1} = sprintf('%s set to %g, the data holds no such column',name,default);

end
