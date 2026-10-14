function factor = getUnitScale(unit)
% length of a unit in meter
%
% Syntax
%
%   factor = getUnitScale('um')   % 1e-6
%
% Input
%  unit - unit of length, one of ym, zm, am, fm, pm, au (Angstrom, 1e-10),
%  nm, um, mm, cm, m, km, Mm, Gm, Tm, Pm, Em, Zm, Ym
%
% Output
%  factor - length of the unit in meter

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

