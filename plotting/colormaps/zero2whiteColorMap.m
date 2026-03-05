function map = zero2whiteColorMap(CLim,n)
% Define a color map which strongly depends on the maximal and minimal
% value of the plot. The colormap plots all positive values with the
% WhiteJetColorMap. The negative values are plotted as magenta.

if nargin < 1
  error('Not enough input arguments.')
end

if nargin == 1, n  = 100; end


if CLim(1)>=0 || CLim(2)<=0
  map = WhiteJetColorMap;
  return
end

% High map
nHigh  = round(n * CLim(2)/(CLim(2)-CLim(1)));
highMap = WhiteJetColorMap(nHigh);

if nHigh==n
  map = WhiteJetColorMap(n);
  return
end

% --- Untere Zone: sanfter Übergang Magenta -> jet-Blau
nLow = n-nHigh;
lowStart = [1 0 1];           % magenta
lowEnd   = highMap(1,:);      % Beginn jet

lowMap = [linspace(lowStart(1),lowEnd(1),nLow)' ...
          linspace(lowStart(2),lowEnd(2),nLow)' ...
          linspace(lowStart(3),lowEnd(3),nLow)'];

% Gesamte Map
map = [lowMap; highMap];

end