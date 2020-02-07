function [odf,alpha] = calcODF(varargin)
% PDF to ODF inversion
%
% *calcODF* is one of the main function of the MTEX toolbox. It estimates
% an ODF from given Polefigure intensities by <PoleFigure2ODF.html fitting
% an ODF that consists of a large number of unimodal ODFs to the data>. It
% does so by minimizing a least squares functional. The command *calcODF*
% supports <PoleFigure2ODFGhostCorrection.html automatic ghost correction> and
% <PoleFigureDubna.html the zero range method>. The function *calcODF* has
% several options to control convergence, resolution, smoothing, etc. See
% below for a complete description.
%
% Syntax
%
%   odf = calcODF(pf)
%   odf = calcODF(pf,'halfwidth',5*degree)
%   odf = calcODF(pf,'zeroRange')
%   odf = calcODF(pf,'resolution',2.5*degree)
%
% Input
%  pf - @PoleFigure
%
% Options
%  kernel     - the ansatz functions (default = de la Vallee Poussin)
%  halfwidth  - halfwidth of the ansatz functions (default = 2/3 * resolution)
%  resolution - localization grid for the ansatz fucntions (default = 3/2 resolution(pf))
%  iterMax    - maximum number of iterations (default = 11)
%  iterMin    - minimum number of iterations (default = 5)
%  c0         - initial guess (default = [1 1 1 1 ... 1])
%
% Flags
%  zeroRange         - apply zero range method (default = )
%  noGhostCorrection - omit ghost correction
%  ensure_descent - stop iteration whenever no procress if observed
%  force_iter_max - allway go until ITER_MAX
%  silent         - no output
%
% Output
%  odf    - reconstructed @ODF
%  alpha  - scaling factors, calculated during reconstruction
%
% See also
% PoleFigure2odf ODF_demo PoleFigureSimulation_demo
% PoleFigure/load ImportPoleFigureData examples_index

solver = getClass(varargin,'pf2odfSolver');
if isempty(solver), solver = MLSSolver(varargin{:}); end

solver.zrm = getClass(varargin,'zeroRangeMethod');
if isempty(solver.zrm) && check_option(varargin,'zeroRange'), solver.zrm = zeroRangeMethod(varargin{:}); end

[odf,alpha] = solver.calcODF(varargin{:});

end

