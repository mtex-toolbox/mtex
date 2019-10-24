function factor = getUnitScale(unit)
%
% Syntax
%   factor = getUnitScale(unit)
%
% Input
%  unit - unit of the value (e.g. nm, m, ...)
%
% Output
%  factor - with repsect to meter
%

% References lookup table
ref_units = {'ym' 'zm' 'am' 'fm' 'pm' 'au' 'nm' 'um' 'mm' 'cm' 'm' ...
             'km' 'Mm' 'Gm' 'Tm' 'Pm' 'Em' 'Zm' 'Ym'};
ref_values = [1e-24, 1e-21, 1e-18, 1e-15, 1e-12, 1e-10, 1e-9, 1e-6, 1e-3,...
  1e-2, 1e-0, 1e3, 1e6, 1e9, 1e12, 1e15, 1e18, 1e21, 1e24];

% Find unit index
n_unit = strcmpi(ref_units,unit);
if ~any(n_unit) % No unit found
  ex = MException('MTEX:BadValue', ['Specified unit (' unit ') is invalid']);
  throw(ex);
else
  factor = ref_values(n_unit);
end

