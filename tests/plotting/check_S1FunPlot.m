function check_S1FunPlot
% check that S1Fun/plot forwards its plotting options
%
% Split out of check_S1Fun, whose other half is arithmetic and lives in
% core/. The assertion here is on a line object's LineWidth, i.e. on a
% graphics property, which is what puts it in this tier - although what it
% really pins is option passthrough rather than layout: 'linewidth' has to
% survive both the polar and the 'notPolar' branch of plot.
%
% Figures are invisible and closed by runTests, so this file does not manage
% DefaultFigureVisible itself. The version in check_S1Fun did, and restored
% it to 'on' unconditionally rather than to what it found - so an early error
% left the setting changed for the rest of the session.
%
% See also
% S1Fun/plot check_S1Fun

f = S1FunHandle(@(x) cos(2*x) + 0.5*sin(x) + 0.3);
F = S1FunHarmonic(f);

h = plot(F,'linewidth',2,'notPolar');
lw = h.LineWidth;

h = plot(F,'linewidth',3,'color','r');
lwPolar = h.LineWidth;

if lw ~= 2
  error('plot(sF,''notPolar'') ignores the plotting options - LineWidth is %g, expected 2',lw);
end
if lwPolar ~= 3
  error('plot(sF) ignores the plotting options - LineWidth is %g, expected 3',lwPolar);
end

disp('check_S1FunPlot: passed')

end
