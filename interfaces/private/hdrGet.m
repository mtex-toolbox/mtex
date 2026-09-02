function v = hdrGet(ebsd,names,default)
% one value of the header of the file a map was imported from, or a default
%
% Description
%
% The loaders keep everything a file header states in |ebsd.opt.header|,
% with the keys spelled as the file spelled them (made into valid field
% names). An exporter looks a value up by any of the spellings it may have
% and falls back to a default - the type of the default decides whether a
% number or a string is wanted.
%
% Syntax
%   v = hdrGet(ebsd,{'x_star','xstar'},0)
%
% Input
%  ebsd    - @EBSD
%  names   - cell array of possible keys
%  default - value to return when none of them is there
%
% Output
%  v - the header value, in the type of the default

v = default;

if ~isfield(ebsd.opt,'header'), return; end
hdr = ebsd.opt.header;
fn = fieldnames(hdr);

for i = 1:numel(names)

  j = find(strcmpi(fn,names{i}),1);
  if isempty(j), continue; end
  val = hdr.(fn{j});

  if ischar(default) || isstring(default)
    v = char(string(val));
  elseif isnumeric(val)
    v = double(val);
  else
    v = str2double(string(val));
    if isnan(v), v = default; end
  end
  return

end

end
