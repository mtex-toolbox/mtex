function map = vega20(N)
% Colormap from MatPlotLib 2.0. For attractive plots using the ColorOrder.
%
%%% Syntax:
%  map = vega20
%  map = vega20(N)
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
% axes('ColorOrder',vega20(N),'NextPlot','replacechildren')
% X = linspace(0,pi*3,1000);
% Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X(:), 1:N);
% plot(X,Y, 'linewidth',4)
%
%%% PLOT in a loop:
% N = 20;
% set(0,'DefaultAxesColorOrder',vega20(N))
% X = linspace(0,pi*3,1000);
% Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X(:), 1:N);
% for n = 1:N
%     plot(X(:),Y(:,n), 'linewidth',4);
%     hold all
% end
%
%%% LINE using matrices:
% N = 20;
% set(0,'DefaultAxesColorOrder',vega20(N))
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
% map = vega20(N)

if nargin<1
	N = size(get(gcf,'colormap'),1);
else
	assert(isscalar(N)&&isreal(N),'First argument must be a real numeric scalar.')
	assert(fix(N)==N&&N>=0,'First argument must be a positive integer.')
end
%
raw = [...
	031,119,180;... #1f77b4
	174,199,232;... #aec7e8
	255,127,014;... #ff7f0e
	255,187,120;... #ffbb78
	044,160,044;... #2ca02c
	152,223,138;... #98df8a
	214,039,040;... #d62728
	255,152,150;... #ff9896
	148,103,189;... #9467bd
	197,176,213;... #c5b0d5
	140,086,075;... #8c564b
	196,156,148;... #c49c94
	227,119,194;... #e377c2
	247,182,210;... #f7b6d2
	127,127,127;... #7f7f7f
	199,199,199;... #c7c7c7
	188,189,034;... #bcbd22
	219,219,141;... #dbdb8d
	023,190,207;... #17becf
	158,218,229;... #9edae5
	];
%
map = raw(1+mod(0:N-1,size(raw,1)),:) / 255;
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%vega20
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