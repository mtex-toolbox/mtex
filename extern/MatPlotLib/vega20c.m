function map = vega20c(N)
% Colormap from MatPlotLib 2.0. For attractive plots using the ColorOrder.
%
%%% Syntax:
%  map = vega20c
%  map = vega20c(N)
%
% For MatPlotLib 2.0 improved colormaps were created for plot lines of
% categorical data. The new colormaps are introduced here:
% <http://matplotlib.org/2.0.0rc2/users/dflt_style_changes.html>
% <https://github.com/vega/vega/wiki/Scales#scale-range-literals>
% Note that VEGA10 is the new default Line Color Order for MatPlotLib 2.0.
%
% Information on the axes ColorOrder (note that this is NOT the axes COLORMAP):
% <https://www.mathworks.com/help/matlab/creating_plots/defining-the-color-of-lines-for-plotting.html>
% <https://www.mathworks.com/help/matlab/graphics_transition/why-are-plot-lines-different-colors.html>
%
%% Examples %%
%
%%% PLOT using matrices:
% N = 20;
% axes('ColorOrder',vega20c(N),'NextPlot','replacechildren')
% X = linspace(0,pi*3,1000);
% Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X(:), 1:N);
% plot(X,Y, 'linewidth',4)
%
%%% PLOT in a loop:
% N = 20;
% set(0,'DefaultAxesColorOrder',vega20c(N))
% X = linspace(0,pi*3,1000);
% Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X(:), 1:N);
% for n = 1:N
%     plot(X(:),Y(:,n), 'linewidth',4);
%     hold all
% end
%
%%% LINE using matrices:
% N = 20;
% set(0,'DefaultAxesColorOrder',vega20c(N))
% X = linspace(0,pi*3,1000);
% Y = bsxfun(@(x,n)n*cos(x+2*n*pi/N), X(:), 1:N);
% line(X(:),Y)
%
%% Input and Output Arguments %%
%
%%% Inputs (*=default):
% N = NumericScalar, N>=0, an integer to define the colormap length.
%   = *[], use the length of the current figure's colormap (see COLORMAP).
%
%%% Outputs:
% map = NumericMatrix, size Nx3, a colormap of RGB values between 0 and 1.
%
% map = vega20c(N)

if nargin<1
	N = size(get(gcf,'colormap'),1);
else
	assert(isscalar(N)&&isreal(N),'First argument must be a real numeric scalar.')
	assert(fix(N)==N&&N>=0,'First argument must be a positive integer.')
end
%
raw = [...
	049,130,189;... #3182bd
	107,174,214;... #6baed6
	158,202,225;... #9ecae1
	198,219,239;... #c6dbef
	230,085,013;... #e6550d
	253,141,060;... #fd8d3c
	253,174,107;... #fdae6b
	253,208,162;... #fdd0a2
	049,163,084;... #31a354
	116,196,118;... #74c476
	161,217,155;... #a1d99b
	199,233,192;... #c7e9c0
	117,107,177;... #756bb1
	158,154,200;... #9e9ac8
	188,189,220;... #bcbddc
	218,218,235;... #dadaeb
	099,099,099;... #636363
	150,150,150;... #969696
	189,189,189;... #bdbdbd
	217,217,217;... #d9d9d9
	];
%
map = raw(1+mod(0:N-1,size(raw,1)),:) / 255;
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%vega20c
% The file <vega_license.txt> contains the colormap license.
% This implmentation: Copyright (c) 2017 Stephen Cobeldick
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
% http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and limitations under the License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%license