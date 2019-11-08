function [oval, ounit, factor] = switchUnit(val, unit)
% returns the closest length to a known unit.
% For example, 10e3m will give 10km.
%
% Syntax
%   [fval funit] = closest_value(val, unit)
%
% Input
%  val  - a value
%  unit - unit of the value (e.g. nm, m, ...)
%
% Output
%  oval  - output value 
%  ounit - output unit
%

% References lookup table
ref_units = {'ym' 'zm' 'am' 'fm' 'pm' 'nm' 'um' 'mm' 'm' ...
             'km' 'Mm' 'Gm' 'Tm' 'Pm' 'Em' 'Zm' 'Ym'};
ref_values = [1e-24, 1e-21, 1e-18, 1e-15, 1e-12, 1e-9, 1e-6, 1e-3, 1e-0,...
              1e3, 1e6, 1e9, 1e12, 1e15, 1e18, 1e21, 1e24];

% Find unit index
n_unit = ismember(ref_units, unit)==1; 
if any(n_unit) == 0 % No unit found
    ex = MException('MTEX:BadValue', ...
        ['Specified unit (' unit ') is invalid']);
    throw(ex);
end

val_m = val * ref_values(n_unit); % Convert to meters
pow = floor(log10(val_m)); % Get power of value
n = floor(pow / 3) + 9; % Get the closest unit

% Check if n is in array
if n < 1
    ex = MException('MTEX:BadValue', ...
            ['Specified value (' num2str(val_m) ' m) is too small']);
    throw(ex);
elseif n >= length(ref_units)
   ex = MException('MTEX:BadValue', ...
            ['Specified value (' num2str(val_m) ' m) is too large']);
    throw(ex);
end 

ounit = char(ref_units(n)); % Return units
oval = val_m / ref_values(n); % Return formatted value

factor = ref_values(n) ./ ref_values(n_unit);

end % closest_length
