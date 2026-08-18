function v = hdrGet(hdr,names,default)
% one value of an imported file header, or a default
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
%   v = hdrGet(hdr,{'x_star','xstar'},0)
%
% Input
%  hdr     - struct, as kept in ebsd.opt.header
%  names   - cell array of possible keys
%  default - value to return when none of them is there
%
% Output
%  v - the header value, in the type of the default

v = default;

if ~isstruct(hdr) || isempty(fieldnames(hdr)), return; end

wantChar = ischar(default) || isstring(default);
fn = fieldnames(hdr);

for i = 1:numel(names)

  j = find(strcmpi(fn,names{i}),1);
  if isempty(j), continue; end

  val = hdr.(fn{j});

  if wantChar

    if ischar(val) || isstring(val)
      v = char(val); return
    elseif isnumeric(val) && isscalar(val)
      v = num2str(val); return
    end

  else

    if isnumeric(val) && isscalar(val)
      v = double(val); return
    elseif (ischar(val) || isstring(val)) && ~isnan(str2double(val))
      v = str2double(val); return
    end

  end

end

end
