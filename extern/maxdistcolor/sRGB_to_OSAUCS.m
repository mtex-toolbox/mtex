function Ljg = sRGB_to_OSAUCS(rgb,isd,isc)
% Convert a matrix of sRGB R G B values to OSA-UCS L j g values.
%
% (c) 2020-2020 Stephen Cobeldick
%
%%% Syntax:
% Ljg = sRGB_to_OSAUCS(rgb)
% Ljg = sRGB_to_OSAUCS(rgb,isd)
% Ljg = sRGB_to_OSAUCS(rgb,isd,isc)
%
% If the output is being used for calculating the Euclidean color distance
% (i.e. deltaE) use isd=true, so that L is NOT divided by sqrt(2).
%
% The reference formula divides by zero when Y0^(1/3)==2/3 (dark colors),
% this unfortunate numeric discontinuity can be avoided with isc=true.
%
% https://en.wikipedia.org/wiki/SRGB
% https://en.wikipedia.org/wiki/OSA-UCS
%
%% Examples %%
%
% >> rgb = [0.705726156324052,0.192325064670146,0.223532407186411];
% >> sRGB_to_OSAUCS(rgb)
% ans =
%   -3.0045   2.9971  -9.6678
%
%% Inputs and Outputs
%
%%% Input Argument (*==default):
% rgb = NumericArray, size Nx3 or RxCx3, where the last dimension
%       encodes sRGB values [R,G,B] in the range 0<=RGB<=1.
% isd = LogicalScalar, true/false* = Euclidean distance/reference output values.
% isc = LogicalScalar, true/false* = modified continuous/reference output values.
%
%%% Output Argument:
% Ljg = Numeric Array, same size as <rgb>, where the last dimension
%       encodes OSA-UCS values [L,j,g].
%
% See also SRGB_TO_CAM02UCS SRGB_TO_CIELAB CIELAB_TO_SRGB CIELAB_TO_DIN99
% MAXDISTCOLOR MAXDISTCOLOR_VIEW MAXDISTCOLOR_DEMO

%% Input Wrangling %%
%
isz = size(rgb);
assert(isnumeric(rgb),...
	'SC:sRGB_to_OSAUCS:rgb:NotNumeric',...
	'1st input <rgb> array must be numeric.')
assert(isreal(rgb),...
	'SC:sRGB_to_OSAUCS:rgb:ComplexValue',...
	'1st input <rgb> cannot be complex.')
assert(isz(end)==3,...
	'SC:sRGB_to_OSAUCS:rgb:InvalidSize',...
	'1st input <rgb> last dimension must have size 3 (e.g. Nx3 or RxCx3).')
rgb = reshape(rgb,[],3);
assert(all(rgb(:)>=0&rgb(:)<=1),...
	'SC:sRGB_to_OSAUCS:rgb:OutOfRange',...
	'1st input <rgb> values must be within the range 0<=rgb<=1')
%
if ~isfloat(rgb)
	rgb = double(rgb);
end
%
assert(nargin<2||ismember(isd,0:1),...
	'SC:sRGB_to_OSAUCS:isd:NotScalarLogical',...
	'Second input <isd> must be true/false.')
ddd = 2-(nargin>1&&isd);
%
assert(nargin<3||ismember(isc,0:1),...
	'SC:sRGB_to_OSAUCS:isc:NotScalarLogical',...
	'Third input <isc> must be true/false.')
ccc = 30*(nargin>2&&isc);
%
%% RGB2Ljg %%
%
M = [... High-precision sRGB to XYZ matrix:
	0.4124564,0.3575761,0.1804375;...
	0.2126729,0.7151522,0.0721750;...
	0.0193339,0.1191920,0.9503041];
% Source: http://brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
%
cr = @(x)sign(x).*abs(x).^(1/3); % lazy cube root
%
% RGB2XYZ
XYZ = 100 * sGammaInv(rgb) * M.';
%
% XYZ2Ljg
xyz = bsxfun(@rdivide,XYZ,sum(XYZ,2));
xyz(isnan(xyz)) = 0;
%
K = 1.8103 + (xyz(:,1:2).^2)*[4.4934;4.3034] - ...
	prod(xyz(:,1:2),2)*4.276 - xyz(:,1:2)*[1.3744;2.5643];
Y0 = K.*XYZ(:,2);
Lp = 5.9*(cr(Y0)-2/3 + 0.042*cr(Y0-30));
L = (Lp-14.3993)./sqrt(ddd);
%C = 1 + (0.042*cr(Y0-30))./(cr(Y0)-2/3); % !!!!! divide by zero !!!!!
C = 1 + (0.042*cr(Y0-30))./(cr(max(ccc,Y0))-2/3);
tmp = cr(XYZ*[0.799,0.4194,-0.1648;-0.4493,1.3265,0.0927;-0.1149,0.3394,0.717].');
a = tmp*[-13.7;17.7;-4];
b = tmp*[1.7;8;-9.7];
%
Ljg = reshape([L,C.*b,C.*a],isz);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%sRGB_to_OSAUCS
function rgb = sGammaInv(rgb)
% Inverse gamma correction of sRGB data.
idx = rgb <= 0.04045;
rgb(idx) = rgb(idx) / 12.92;
rgb(~idx) = real(((rgb(~idx) + 0.055) / 1.055).^2.4);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%sGammaInv