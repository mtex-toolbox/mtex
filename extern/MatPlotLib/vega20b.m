function map = vega20b(N)
% Colormap from MatPlotLib 2.0. For attractive plots using the ColorOrder.
%
%%% Syntax:
%  map = vega20b
%  map = vega20b(N)
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
% axes('ColorOrder',vega20b(N),'NextPlot','replacechildren')
% X = linspace(0,pi*3,1000);
% Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X(:), 1:N);
% plot(X,Y, 'linewidth',4)
%
%%% PLOT in a loop:
% N = 20;
% set(0,'DefaultAxesColorOrder',vega20b(N))
% X = linspace(0,pi*3,1000);
% Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X(:), 1:N);
% for n = 1:N
%     plot(X(:),Y(:,n), 'linewidth',4);
%     hold all
% end
%
%%% LINE using matrices:
% N = 20;
% set(0,'DefaultAxesColorOrder',vega20b(N))
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
% map = vega20b(N)

if nargin<1
	N = size(get(gcf,'colormap'),1);
else
	assert(isscalar(N)&&isreal(N),'First argument must be a real numeric scalar.')
	assert(fix(N)==N&&N>=0,'First argument must be a positive integer.')
end
%
raw = [...
	057,059,121;... #393b79
	082,084,163;... #5254a3
	107,110,207;... #6b6ecf
	156,158,222;... #9c9ede
	099,121,057;... #637939
	140,162,082;... #8ca252
	181,207,107;... #b5cf6b
	206,219,156;... #cedb9c
	140,109,049;... #8c6d31
	189,158,057;... #bd9e39
	231,186,082;... #e7ba52
	231,203,148;... #e7cb94
	132,060,057;... #843c39
	173,073,074;... #ad494a
	214,097,107;... #d6616b
	231,150,156;... #e7969c
	123,065,115;... #7b4173
	165,081,148;... #a55194
	206,109,189;... #ce6dbd
	222,158,214;... #de9ed6
	];
%
map = raw(1+mod(0:N-1,size(raw,1)),:) / 255;
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%vega20b
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