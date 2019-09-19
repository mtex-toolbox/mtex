%% COLORNAMES Examples
% The function <https://www.mathworks.com/matlabcentral/fileexchange/48155
% |COLORNAMES|> matches the input RGB values or color names to the
% closest colors from the selected palette. |COLORNAMES| returns the
% same outputs whether matching names or RGB:
%
%  [names,RGB] = colornames(palette,RGB)
%  [names,RGB] = colornames(palette,names)
%
% This document shows some examples of using |COLORNAMES| to match
% RGB values or color names. The bonus functions are also explained in this
% document, together with examples.
%% Palette Descriptions
% Palettes of named colors have been defined by various people and groups,
% often intended for very different applications. |COLORNAMES| supports a
% wide selection of common color palettes: a detailed list of the supported
% palettes is printed in the command window by simply calling |COLORNAMES|
% with no input arguments and no output arguments:
colornames()
%% Return Palette Names
% To return a cell array of the supported palettes simply call
% |COLORNAMES| with no input arguments and one output argument:
palettes = colornames()
%% Return All Color Names and RGB Values for One Palette
% Simply call |COLORNAMES| with the name of the required palette:
[clr,rgb] = colornames('MATLAB')
%% Match Color Names
% Each input name is matched to a color name from the requested palette: an
% input name that does not match any of the color names will throw an error.
% The matching is very flexible though, as COLORNAMES usually makes a match
% regardless of spaces between words and character case, although for some
% palettes space characters may be significant. Note that CamelCase always
% signifies separate words (words all in one case are considered one word).
%
% The color names are input as char row vectors and may supplied either
% within one cell array or as separate input arguments:
[clr,rgb] = colornames('xkcd',{'red','green','blue'})
[clr,rgb] = colornames('xkcd','eggshell','eggShell')
%% Match Index Number
% Palettes with a leading index number may be matched by just the number,
% or just the name, or both together:
colornames('CGA','9','LightBlue','9LightBlue')
%% Match Initial Letter
% Palettes Alphabet, MATLAB, and Natural also match the initial letter to
% the color name (except for 'Black' which is matched by 'k'):
colornames('MATLAB','c','m','y','k')
%% Match RGB
% Each input RGB triple is matched to the closest RGB triple from the
% requested palette:
[clr,rgb] = colornames('HTML4', [0,0.2,1;1,0.2,0])
%% Match RGB, Selecting the Color Difference Metric
% Input RGB values are matched using one of several standard, well defined
% <https://en.wikipedia.org/wiki/Color_difference color difference>
% metrics known as $\Delta E$ or _deltaE_. The default color difference is
% "CIE94", which provides good matching for most palettes and colors. Other
% deltaE calculations can be selected by using the third input argument:
rgb = [0,0.5,1];
colornames('HTML4',rgb,'CIEDE2000')
colornames('HTML4',rgb,'CIE94') % default.
colornames('HTML4',rgb,'CIE76') % i.e. CIELAB.
colornames('HTML4',rgb,'DIN99') % better than CIELAB.
colornames('HTML4',rgb,'CMCl:c')
colornames('HTML4',rgb,'RGB')
%% View the Color Difference Metrics in a Figure
% The helper function |COLORNAMES_DELTAE| demonstrates how the different
% deltaE metrics match the input RGB to the palette colors. Simply
% select the palette, provide an Nx3 colormap and all deltaE metrics
% are listed, with the matched colors displayed in the columns below:
colornames_deltaE('HTML4',jet(16))
%% View the Palette Colors in 2D
% The helper function |COLORNAMES_VIEW| plots the palettes in a figure.
% Drop-down menus select the palette, and also how the colors are sorted.
% Click on any color to view its hex RGB value (may be approximate).
colornames_view('dvips','Lab')
%% View the Palette Colors in 3D
% The helper function |COLORNAMES_CUBE| plots the palettes in a figure.
% The <http://www.mathworks.com/help/matlab/creating_plots/data-cursor-displaying-data-values-interactively.html
% data cursor> can be used to view the color names, by clicking on the nodes.
% Drop-down menus select the palette, and the color space of the colorcube:
colornames_cube('CSS','Lab')
%% Unmatched Color Name Error
% If the input color name cannot be matched then |COLORNAMES| will throw an
% error, and displays color names that are similar to the input string/s:
colornames('CSS', 'bleu', 'blanc', 'rouge')