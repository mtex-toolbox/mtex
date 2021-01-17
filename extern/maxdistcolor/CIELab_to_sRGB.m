function rgb = CIELab_to_sRGB(Lab)
% Convert a matrix of CIELAB L* a* b* values to sRGB R G B values.
%
% (c) 2018-2020 Stephen Cobeldick
%
%%% Syntax:
% rgb = CIELab_to_sRGB(Lab)
%
% https://en.wikipedia.org/wiki/Lab_color_space
% https://en.wikipedia.org/wiki/SRGB
%
%% Examples %%
%
% >> CIELab_to_sRGB([68.18,2.14,-43.8])*255
% ans =
%   109.0000  169.0000  245.0000
%
% >> CIELab_to_sRGB([0,0,0;100,0,0])
% ans =
%          0         0         0
%     1.0000    1.0000    1.0000
%
%% Inputs and Outputs
%
%%% Input Argument:
% Lab = Numeric Array, size Nx3 or RxCx3, where the last dimension
%       encodes CIELAB values [L*,a*,b*] in the range 0<=L*<=100.
%
%%% Output Argument:
% rgb = Numeric Array, same size as <Lab>, where the last dimension
%       encodes sRGB values [R,G,B] in the range 0<=RGB<=1.
%
% See also CIELAB_TO_DIN99 SRGB_TO_CIELAB SRGB_TO_CAM02UCS SRGB_TO_OSAUCS
% MAXDISTCOLOR MAXDISTCOLOR_VIEW MAXDISTCOLOR_DEMO

%% Input Wrangling %%
%
isz = size(Lab);
assert(isnumeric(Lab),...
	'SC:CIELab_to_sRGB:Lab:NotNumeric',...
	'1st input <Lab> must be numeric.')
assert(isreal(Lab),...
	'SC:CIELab_to_sRGB:Lab:ComplexValue',...
	'1st input <Lab> cannot be complex.')
assert(isz(end)==3,...
	'SC:CIELab_to_sRGB:Lab:InvalidSize',...
	'1st input <Lab> last dimension must have size 3 (e.g. Nx3 or RxCx3).')
Lab = reshape(Lab,[],3);
assert(all(Lab(:,1)>=0&Lab(:,1)<=100),...
	'SC:CIELab_to_sRGB:Lab:OutOfRange',...
	'1st input <Lab> L values must be within the range 0<=L<=100')
%
if ~isfloat(Lab)
	Lab = double(Lab);
end
%
%% Lab2RGB %%
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
%rgb = applycform(lab,makecform('lab2srgb','AdaptedWhitePoint',wpt))
%
% Lab2XYZ
tmp = bsxfun(@rdivide,Lab(:,[2,1,3]),[500,Inf,-200]);
tmp = bsxfun(@plus,tmp,(Lab(:,1)+16)/116);
idx = tmp>(6/29);
tmp = idx.*(tmp.^3) + ~idx.*(3*(6/29)^2*(tmp-4/29));
XYZ = bsxfun(@times,tmp,wpt);
%
% XYZ2RGB
rgb = max(0,min(1,sGammaCor(XYZ / M.')));
%
rgb = reshape(rgb,isz);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Lab_to_sRGB
function rgb = sGammaCor(rgb)
% Gamma correction of sRGB data.
idx = rgb <= 0.0031308;
rgb(idx) = 12.92 * rgb(idx);
rgb(~idx) = real(1.055 * rgb(~idx).^(1/2.4) - 0.055);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%sGammaCor