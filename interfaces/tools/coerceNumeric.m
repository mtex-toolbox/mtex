function value = coerceNumeric(value)
% convert a char value to double if it parses as a number, otherwise
% return it unchanged
%
% Syntax
%   value = coerceNumeric(value)

if ~ischar(value) && ~isstring(value), return; end

numValue = str2double(value);
if ~isnan(numValue) && ~isempty(value)
  value = numValue;
end

end
