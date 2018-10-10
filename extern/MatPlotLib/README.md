Colormaps from MatPlotLib 2.0
=========

The MatPlotLib 2.0 default colormaps ported to MATLAB. This submission also includes the Line ColorOrder colormaps!

For version 2.0 of MatPlotLib new perceptually uniform colormaps were generated in the CAM02-UCS colorspace. The process is described here: <http://matplotlib.org/2.0.0rc2/users/dflt_style_changes.html>. The colormap data is available here <https://bids.github.io/colormap/> and the line ColorOrder data here <https://github.com/vega/vega/wiki/Scales#scale-range-literals>.

The default MatPlotLib colormap was changed to the newly created VIRIDIS, replacing the awful JET/RAINBOW. The default Line ColorOrder was also changed to VEGA10.

For the colormaps INFERNO, MAGMA, PLASMA, and VIRIDIS: interpolation occurs within the Lab colorspace: users who do not wish to bother with Lab interpolation can easily edit the Mfiles and interpolate in RGB.

For the colormaps VEGA10, VEGA20, VEGA20B, and VEGA20C: the colormap values are repeated for colormaps larger than the number of defining colors.

### COLORMAP Examples ###

    %% Plot the scheme's RGB values:
    rgbplot(viridis(256))

    %% New colors for the COLORMAP example:
    load spine
    image(X)
    colormap(viridis)

    %% New colors for the SURF example:
    [X,Y,Z] = peaks(30);
    surfc(X,Y,Z)
    colormap(viridis)
    axis([-3,3,-3,3,-10,5])

### COLORORDER Examples ###

    %% PLOT using matrices:
    N = 10;
    axes('ColorOrder',vega10(N),'NextPlot','replacechildren')
    X = linspace(0,pi*3,1000);
    Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X(:), 1:N);
    plot(X,Y, 'linewidth',4)

    %% PLOT in a loop:
    N = 10;
    set(0,'DefaultAxesColorOrder',vega10(N))
    X = linspace(0,pi*3,1000);
    Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X(:), 1:N);
    for n = 1:N
        plot(X(:),Y(:,n), 'linewidth',4);
    hold all
    end

    %% LINE using matrices:
    N = 10;
    set(0,'DefaultAxesColorOrder',vega10(N))
    X = linspace(0,pi*3,1000);
    Y = bsxfun(@(x,n)n*cos(x+2*n*pi/N), X(:), 1:N);
    line(X(:),Y)
