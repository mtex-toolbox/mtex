function map = vega10(N)
% Colormap from MatPlotLib 2.0. For attractive plots using the ColorOrder.
%
%%% Syntax:
%  map = vega10
%  map = vega10(N)
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
% N = 10;
% axes('ColorOrder',vega10(N),'NextPlot','replacechildren')
% X = linspace(0,pi*3,1000);
% Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X(:), 1:N);
% plot(X,Y, 'linewidth',4)
%
%%% PLOT in a loop:
% N = 10;
% set(0,'DefaultAxesColorOrder',vega10(N))
% X = linspace(0,pi*3,1000);
% Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X(:), 1:N);
% for n = 1:N
%     plot(X(:),Y(:,n), 'linewidth',4);
%     hold all
% end
%
%%% LINE using matrices:
% N = 10;
% set(0,'DefaultAxesColorOrder',vega10(N))
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
% map = vega10(N)

if nargin<1
	N = size(get(gcf,'colormap'),1);
else
	assert(isscalar(N)&&isreal(N),'First argument must be a real numeric scalar.')
	assert(fix(N)==N&&N>=0,'First argument must be a positive integer.')
end
%
raw = [...
	031,119,180;... #1f77b4
	255,127,014;... #ff7f0e
	044,160,044;... #2ca02c
	214,039,040;... #d62728
	148,103,189;... #9467bd
	140,086,075;... #8c564b
	227,119,194;... #e377c2
	127,127,127;... #7f7f7f
	188,189,034;... #bcbd22
	023,190,207;... #17becf
	];
%
map = raw(1+mod(0:N-1,size(raw,1)),:) / 255;
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%vega10
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