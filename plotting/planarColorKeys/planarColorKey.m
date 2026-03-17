classdef planarColorKey
    % planarColorKey  encode two scalar properties as hue × saturation colors
    %
    %   * Property 1  →  Hue        (sampled from a user-supplied or default LUT)
    %   * Property 2  →  Saturation (linearly from 0 or 1 to full color)
    %
    %
    % Syntax
    %   cK = planarColorKey
    %   cK = planarColorKey(winter, 'colorModel', 'white', ...)
    %
    %   rgb = cK.property2color(v1, v2)
    %
    %   plot(cK)                % standalone legend (key image only, no labels)
    %   plot(cK, 'labeled')     % legend with labels according to data range
    %
    % Properties
    %   colorMap    - n-by-3 hue look-up table.
    %   colorModel  - 'white' (default) | 'black'  what zero-saturation maps to
    %   periode     - frequency of periodic data (pi/2*pi), wrapping v1. Default: NaN
    %   quantileCap - quantile for maximum of v2.  Default: 0.975
    %   range1      - data range of v1.  Default: [min(v1), max(v1)]
    %   range2      - data range of v2.  Default: [min(v2), quantile(v2,0.975)]
    %   label1      - x-axis label in plot().  Default: 'Property 1'
    %   label2      - y-axis label in plot().  Default: 'Property 2'
    %
    % Examples:
    %
    % % Example 1: long axis mapping, with saturatiion given by aspect ratio
    % % get the data
    % mtexdata martensite
    % grains = ebsd('indexed').calcGrains('minPixel',5);
    % asr  = grains('indexed').aspectRatio;
    % lax  = grains('indexed').longAxis;
    % % set up colormap
    % pK = planarColorKey(colorcet('C2'))
    % % since long axis direction is periodic and antipodal (=pi)
    % pK.periode = pi;
    %
    % pK.label1 = 'phi'
    % pK.label2 = 'a/b'
    % % plot a map
    % plot(grains('indexed'),pK.property2color(mod(lax.rho,pi)/degree,asr))
    % % and a colorbar
    %
    % figure
    % plot(pK,mod(lax.rho,pi)/degree,asr)
    %
    % % alternatively use radians
    %
    % figure
    % plot(pK,mod(lax.rho,pi),asr)
    %
    %
    % % example 2:
    % % highlight grains which are large AND have a large aspect ratio
    %
    % v1 = grains('indexed').aspectRatio;
    % v2 = grains('indexed').area;
    %
    % % set a colormap
    % pK = planarColorKey(inferno)
    %
    % % shade to black
    % pK.shading = 'black'
    %
    % % set the range1 for v1
    % pK.range1 = [1 4]
    %
    % % set the autoselection of v2 a little lower
    % pK.quantileCap = 0.9;
    %
    % plot(grains('indexed'),pK.property2color(v1,v2))
    %
    % % set labels
    % pK.label1 = 'asr'
    % pK.label2 = 'area'
    % figure
    % plot(pK,v1,v2)
    %
    %
    %
    % See also: directionColorKey, ipfColorKey, HSVDirectionKey

    % TODO:
    % - add log scaling of saturation
    % - fix first tick entry
    % - add circshift to colormap (which color should be zero)
    % - do we need more than 256 colors for v1?
    %% ------------------------------------------------------------------
    properties

        % Kx3 hue look-up table (full-saturation reference RGB colors, [0,1]).
        colorMap = parula;

        % saturation range for v2
        satRange (2,1) double = [0 1];

        % Controls what zero saturation maps to.
        %   'white' (default)  – desaturated colors fade to white
        %   'black'            – desaturated colors fade to black
        shading char = 'white';

        % treat hue data (v1) modulo the range before hue lookup
        % used for periodic data, et to pi or 2*pi
        % leave at NaN for linear range
        periode (1,1) double = NaN;

        % quantile used to set the automatic upper bound of v2.  Default:
        % 0.975. set to 1 to disable
        quantileCap (1,1) double = 0.975;

        % v1 - hue  NaN triggers auto-detection from data.
        range1 (2,1) double = [NaN NaN];

        % Explicit bounds for v2 (saturation axis).  NaN triggers auto-detection.
        range2 (2,1) double = [NaN NaN];

        % label if key is plotted
        label1 char = 'Property 1';
        label2 char = 'Property 2';
    end

    % ------------------------------------------------------------------
    methods

        % ------------------------------------------------------------------
        function cK = planarColorKey(varargin)
            % construct a 2D colorkey
            %

            % check input and populate map if needed
            if ~isempty(varargin)
                cK.colorMap = populateColors(cK,varargin{1});
            end

            % take care of otehr options eventually passed
            if ~isempty(varargin)
                props = {'satRange','shading', ...
                    'quantileCap','range1','range2', ...
                    'label1','label2'};

                for i = 1:length(props)
                    cK.(props{i}) = get_option(varargin,props{i},cK.(props{i}));
                end
            end
        end

        % ------------------------------------------------------------------
        function rgb = property2color(cK, v1, v2)
            % map two arrays v1 and v2 to N-by-3 rgb
            %
            % Syntax
            %   rgb = cK.property2color(v1, v2)
            %
            % Input
            %   v1 - numeric array, mapped to hue.
            %   v2 - numeric array, mapped to saturation. Same size as v1.
            %
            % Output
            %   rgb - array of size [size(v1), 3] with values in [0,1].

            %   v1/v2: limited to range1 and range2, respectively
            %   v2: may be limited to quantileCap if set

            v1 = v1(:);
            v2 = v2(:);
            assert(numel(v1) == numel(v2), ...
                'planarColorKey.property2color: v1 and v2 must have the same number of elements.');

            % find range bounds
            [mn1, mx1, mn2, mx2] = cK.resolveRange(v1, v2);



            % normalise v1 to [0, 1] (hue axis)

            % case data is periodic extend to full range
            if  ~isnan(cK.periode) % make sure to extend to data range
                if any(v1 > 2*pi) % assume input are not angles
                    v1 = v1*degree;
                end
                t1 = v1 ./ max(v1);

            else % or data is linear, scale to range
                t1 = (v1 - mn1) ./ (mx1 - mn1);
                t1 = max(0, min(1, t1));
            end


            % normalise v2 -> [0, 1]  (saturation axis)
            v2c = max(mn2, min(mx2, v2));
            t2 = (v2c - mn2) ./ (mx2 - mn2);
            t2 = max(0, min(1, t2));

            % get hue from the LUT by linear interpolation

            fidx = t1 .* (size(cK.colorMap,1) - 1) + 1; % distribute values
            lo   = floor(fidx);

            hi   = min(lo + 1, size(cK.colorMap,1));
            frac = fidx - lo;

            % linear interp between adjacent LUT entries
            hueFull = (1 - frac) .* cK.colorMap(lo, :) + frac .* cK.colorMap(hi, :);



            %  blend hue toward white or black using saturation
            sat = cK.satRange(1) + t2 .* (cK.satRange(2) - cK.satRange(1));

            switch cK.shading
                case 'white'
                    % rgb = hueFull * sat + [1 1 1] * (1 - sat)
                    rgb = sat .* hueFull + (1 - sat);

                case 'black'
                    % rgb = hueFull * sat  (goes to [0 0 0])
                    rgb = sat .* hueFull;
            end

            rgb = max(0, min(1, rgb));


        end

        % ------------------------------------------------------------------
        function varargout = plot(cK, varargin)
            % plot the planar color key - optionally as labeled - 2-D image.
            %
            % Syntax
            %   plot(cK)             % color key image only
            %   plot(cK, v1, v2)     % color key, axis ranges and labels
            %   h = plot(...)        % return figure handle
            %
            % the x-axis spans the hue (v1) range (as defined by data or range1);
            % the y-axis spans the saturation (v2) range (as defined by data or range1 or qunatileCap)
            % Labels are taken from cK.label1 and cK.label2.
            %
            % Options (name-value pairs after v1, v2)
            %   'nHue'        - image resolution along hue axis  (default 512)
            %   'nSat'        - image resolution along sat axis  (default 128)


            % case 1: only cK -> plot just the colormap, no labels etc
            if isempty(varargin) | (~isempty(varargin) & ischar(varargin{1}))
                plotCase = 1;
                % case 2: v1,v2 are provided -> plot map with labels and axis
            elseif (isnumeric(varargin{1}) & isnumeric(varargin{2})) & ...
                    numel(varargin{1}) == numel(varargin{2})
                plotCase = 2;
                v1 = varargin{1}; v2 = varargin{2};

            else
                error('Please provide v1,v2 as numeric arrays of identical size')
            end

            % get options
            nHue = get_option(varargin, 'nHue', 256);
            nSat = get_option(varargin, 'nSat', 128);


            % build the 2-D colormap

            xvals = linspace(1,256,nHue); yvals = linspace(1,128,nSat);
            [Xg, Yg] = meshgrid(xvals, yvals);   % nSat x nHue

            % use a copy of the key so that ranges do not interfer
            cKtemp = cK;
            cKtemp.range1 = [NaN NaN];
            cKtemp.range2 = [NaN NaN];

            imgFlat = cKtemp.property2color(Xg, Yg);
            imgRGB  = reshape(imgFlat, [nSat, nHue, 3]);

            % make a plot
            p = image(xvals([1 end]), yvals([1 end]), imgRGB);
            ax = p.Parent;
            ax.YDir = 'normal';
            ax.DataAspectRatio = [1 1 1];
            ax.PlotBoxAspectRatioMode = 'manual';

            switch plotCase
                case 1 % plain map, nothign else

                    ax.XTick = []; ax.YTick = [];

                case 2 % compute ticks, set labels

                    xlabel(ax, cK.label1,'FontSize',getMTEXpref('FontSize'));
                    ylabel(ax, cK.label2,'FontSize',getMTEXpref('FontSize'));


                    % get tickLabels and tickPos
                    [mn1, mx1, mn2, mx2] = cK.resolveRange(v1, v2);


                    % should we assume that if data is periodic it should
                    % be in degree? If there's .periode set AND the data is
                    % > 2*pi, eventually input is in degree
                    if ~isnan(cK.periode ) & (cK.periode == pi | cK.periode == 2*pi)

                        if max(v1) > 2*pi % input is probably in degree

                            maxV1 = cK.periode/degree;
                            ticksX = linspace(0,maxV1,7);
                            labels = num2str(ticksX.');

                        else

                            maxV1 = cK.periode;
                            ticksX = linspace(0,maxV1,5);
                            labels =  {'0' '$\frac{1}{4}\pi$' '$\frac{1}{2}\pi$' '$\frac{3}{4}\pi$' '$\pi$'};
                            ax.TickLabelInterpreter = 'latex';

                        end

                        ax.XTick = ticksX .* nHue / maxV1;
                        ax.XTickLabel =  labels;


                    else % linear data

                        ticksX = niceTicks(mn1, mx1);
                        ax.XTick = floor((ticksX - 1) .* nHue / (mx1 - mn1)) ;
                        ax.XTickLabel =  num2str(ticksX.');

                    end

                    % saturation axis
                    ticksY = niceTicks(mn2, mx2);
                    ax.YTick = floor((ticksY - 1) .* nSat / (mx2 - mn2)) ;
                    ax.YTickLabel = num2str(ticksY.');

            end

            if nargout > 0, varargout{1} = h; end
        end

    end

    % ------------------------------------------------------------------
    methods (Access = private)

        function [mn1, mx1, mn2, mx2] = resolveRange(cK, v1, v2)
            % check if range is specified or not and set min/max
            % accordingly

            % return non-NaN bounds from v1 and v2 and whatever is stored in cK.
            mn1 = cK.range1(1); mx1 = cK.range1(2);
            mn2 = cK.range2(1); mx2 = cK.range2(2);

            if ~isempty(v1)
                if isnan(mn1),  mn1 = min(v1(:));  end
                if isnan(mx1),  mx1 = max(v1(:));  end
            else
                if isnan(mn1),  mn1 = 0;  end
                if isnan(mx1),  mx1 = 1;  end
            end

            if ~isempty(v2)
                if isnan(mn2),  mn2 = min(v2(:)); end

                if isnan(mx2)
                    if cK.quantileCap ~= 1
                        mx2 = quantile(v2(:), cK.quantileCap);
                    else
                        mx2 = max(v2(:));
                    end
                end
            else
                if isnan(mn2),  mn2 = 0;  end
                if isnan(mx2),  mx2 = 1;  end
            end

        end


        % ------------------------------------------------------------------
        function colors = populateColors(cK, varargin)
            % ckeck if inout is m-by-3 or a colormap name

            % take care of colormap
            % LUT provided as M-by-3

            if isnumeric(varargin{1}) & size(varargin{1},2)==3
                colors = varargin{1};
                % LUT provided by name
            elseif ischar(varargin{1})
                colors = eval(varargin{1},256); % maybe that is not optimal
            else
                error(['colorMap was not properly specified. Either leave empty' \newline ...
                    'or provide a n-by-3 colormap or a character string with' \newline ...
                    'the colormap name']);
            end
        end
    end

end

% ------------------------------------------------------------------
function [ticks] = niceTicks(mn, mx)
% find tick labels which are nice numbers

% candidate step sizes
mag      = 10 ^ floor(log10(mx - mn));
cands    = [20, 10, 5, 3, 2, 1, 0.5, 0.2, 0.1] * mag;

ticks     = [];
best_step = NaN;

for step = cands
    lo = ceil (mn / step) * step;
    hi = floor(mx / step) * step;

    % round a little
    lo = round(lo / step) * step;
    hi = round(hi / step) * step;

    t = lo : step : hi;
    t = t(t >= mn & t <= mx);   % values need to be inside

    if numel(t) >= 3 && numel(t) <= 6
        ticks     = t;
        best_step = step;
    end
end

% include mn/mx if they are also "nice"
if ticks(1) ~= mn & abs(best_step - mn) < 1e-5
    ticks = [mn ticks];
end

if ticks(end) ~= mx & abs(ticks(end) + best_step  - mx) < 1e-5
    ticks = [ticks mx];
end

end

