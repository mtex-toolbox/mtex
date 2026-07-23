function header = buildHeaderStruct(keys,values)
% assemble a flat struct from parallel cell arrays of header keys/values
%
% Syntax
%   header = buildHeaderStruct(keys,values)
%
% Input
%  keys   - cell array of char, header field names as found in the file
%  values - cell array of char, corresponding raw values
%
% Output
%  header - struct, one field per key
%
% Notes
%  Keys are sanitized into valid MATLAB field names. Values that parse as
%  numeric are converted to double (mirrors the behaviour already used by
%  the .cpr header parser), everything else is kept as trimmed char.

header = struct();

for k = 1:numel(keys)

  fn = matlab.lang.makeValidName(strtrim(keys{k}));
  if isempty(fn), continue; end

  value = strtrim(values{k});
  numValue = str2double(value);
  if ~isnan(numValue) && ~isempty(value)
    value = numValue;
  end

  header.(fn) = value;

end

end
