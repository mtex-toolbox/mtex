function Lab99 = CIELab_to_DIN99(Lab)
% Convert a matrix of CIELAB L* a* b* values to DIN99 L99 a99 b99 values (DIN 6176).
%
% (c) 2018-2020 Stephen Cobeldick
%
%%% Syntax:
% Lab99 = CIELab_to_DIN99(Lab)
%
%% Inputs and Outputs
%
%%% Input Argument:
% Lab = Numeric Array, size Nx3 or RxCx3, where the last dimension
%       encodes CIELAB values [L*,a*,b*] in the range 0<=L*<=100.
%
%%% Output Argument:
% Lab99 = Numeric Array, same size as <Lab>, where the last dimension
%         encodes the DIN99 values [L99,a99,b99].
%
% See also CIELAB_TO_SRGB SRGB_TO_CIELAB SRGB_TO_CAM02UCS SRGB_TO_OSAUCS
% MAXDISTCOLOR MAXDISTCOLOR_VIEW MAXDISTCOLOR_DEMO

%% Input Wrangling %%
%
isz = size(Lab);
assert(isnumeric(Lab),...
	'SC:CIELab_to_DIN99:Lab:NotNumeric',...
	'1st input <Lab> must be numeric.')
assert(isreal(Lab),...
	'SC:CIELab_to_DIN99:Lab:ComplexValue',...
	'1st input <Lab> cannot be complex.')
assert(isz(end)==3,...
	'SC:CIELab_to_DIN99:Lab:InvalidSize',...
	'1st input <Lab> last dimension must have size 3 (e.g. Nx3 or RxCx3).')
Lab = reshape(Lab,[],3);
assert(all(Lab(:,1)>=0&Lab(:,1)<=100),...
	'SC:CIELab_to_DIN99:Lab:OutOfRange',...
	'1st input <Lab> L values must be within the range 0<=L<=100')
%
if ~isfloat(Lab)
	Lab = double(Lab);
end
%
%% Lab2DIN99 %%
%
L99 = 105.51 * log(1 + 0.0158*Lab(:,1));
e =     (Lab(:,2).*cosd(16)+Lab(:,3).*sind(16));
f = 0.7*(Lab(:,3).*cosd(16)+Lab(:,2).*sind(16));
G = sqrt(e.^2 + f.^2);
C99 = log(1 + 0.045*G)./0.045;
h99 = atan2(f,e);
a99 = C99 .* cos(h99);
b99 = C99 .* sin(h99);
%
Lab99 = reshape([L99,a99,b99],isz);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CIELab_to_DIN99