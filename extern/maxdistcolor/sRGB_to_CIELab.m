function Lab = sRGB_to_CIELab(rgb)
% Convert a matrix of sRGB R G B values to CIELAB L* a* b* values.
%
% (c) 2018-2020 Stephen Cobeldick
%
%%% Syntax:
% Lab = sRGB_to_CIELab(rgb)
%
% https://en.wikipedia.org/wiki/SRGB
% https://en.wikipedia.org/wiki/CIELAB_color_space
%
%% Examples %%
%
% >> sRGB_to_CIELab([109,169,245]/255)
% ans =
%    68.1800    2.1400  -43.8000
%
% >> sRGB_to_CIELab([0,0,0;1,1,1])
% ans =
%          0         0         0
%   100.0000    0.0000    0.0000
%
%% Inputs and Outputs
%
%%% Input Argument:
% rgb = Numeric Array, size Nx3 or RxCx3, where the last dimension
%       encodes sRGB values [R,G,B] in the range 0<=RGB<=1.
%
%%% Output Argument:
% Lab = Numeric Array, same size as <rgb>, where the last dimension
%       encodes CIELAB values [L*,a*,b*] in the range 0<=L*<=100.
%
% See also SRGB_TO_CAM02UCS SRGB_TO_OSAUCS CIELAB_TO_SRGB CIELAB_TO_DIN99
% MAXDISTCOLOR MAXDISTCOLOR_VIEW MAXDISTCOLOR_DEMO

%% Input Wrangling %%
%
isz = size(rgb);
assert(isnumeric(rgb),...
	'SC:sRGB_to_CIELab:rgb:NotNumeric',...
	'1st input <rgb> array must be numeric.')
assert(isreal(rgb),...
	'SC:sRGB_to_CIELab:rgb:ComplexValue',...
	'1st input <rgb> cannot be complex.')
assert(isz(end)==3,...
	'SC:sRGB_to_CIELab:rgb:InvalidSize',...
	'1st input <rgb> last dimension must have size 3 (e.g. Nx3 or RxCx3).')
rgb = reshape(rgb,[],3);
assert(all(rgb(:)>=0&rgb(:)<=1),...
	'SC:sRGB_to_CIELab:rgb:OutOfRange',...
	'1st input <rgb> values must be within the range 0<=rgb<=1')
%
if ~isfloat(rgb)
	rgb = double(rgb);
end
%
%% RGB2Lab %%
%
M = [... High-precision sRGB to XYZ matrix:
	0.4124564,0.3575761,0.1804375;...
	0.2126729,0.7151522,0.0721750;...
	0.0193339,0.1191920,0.9503041];
% Source: http://brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
%
wpt = [0.95047,1,1.08883]; % D65
%
% Approximately equivalent to this function, requires Image Toolbox:
%lab = applycform(rgb,makecform('srgb2lab','AdaptedWhitePoint',wpt))
%
% RGB2XYZ
XYZ = sGammaInv(rgb) * M.';
%
% XYZ2Lab
XYZ = bsxfun(@rdivide,XYZ,wpt);
idx = XYZ>(6/29)^3;
F = idx.*(XYZ.^(1/3)) + ~idx.*(XYZ*(29/6)^2/3+4/29);
Lab(:,2:3) = bsxfun(@times,[500,200],F(:,1:2)-F(:,2:3));
Lab(:,1) = max(0,min(100,116*F(:,2)-16));
%
Lab = reshape(Lab,isz);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%sRGB_to_CIELab
function rgb = sGammaInv(rgb)
% Inverse gamma correction of sRGB data.
idx = rgb <= 0.04045;
rgb(idx) = rgb(idx) / 12.92;
rgb(~idx) = real(((rgb(~idx) + 0.055) / 1.055).^2.4);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%sGammaInv