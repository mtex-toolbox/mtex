function [odf,alpha] = calcODFIterative(pf,varargin)
% iterative PDF to ODF inversion
%
% *calcODFiterative* solves the PF to ODF inversion problem by iteratively
% adjusting the kernel width, starting with a uniform ODF. 
% 
% Iteratively adjusting the kernel width allows to model ODFs from highly 
% irregularly sampled data, as missing information is modelled by assuming
% volume portions along tori (fibres) justified by a coarser model. This method
% basically provides an elaborated guess for starting values for
% |PoleFigure.calcODF| and may be seen as some form of regularization. 
%
% Syntax
%
%   odf = calcODFIterative(pf)
%   odf = calcODFIterative(pf,'halfwidth',5*degree)
%
% Input
%  pf - @PoleFigure
%
% Options
%  kernel     - the ansatz functions (default = de la Vallee Poussin)
%  halfwidth  - halfwidth of the ansatz functions (default = resolution)
%  resolution - localization grid for the ansatz functions (default = resolution(pf))
%  thinning   - corresponds to zero range, will remove nodes with low volume portion (default = 0.025, i.e. 2.5% of uniform)
%
% Flags
%  nothinning - omit reduction of nodes
%  silent     - no output
%
% Output
%  odf    - reconstructed @SO3Fun
%  alpha  - scaling factors, calculated during reconstruction
%
% References
%
% <https://doi.org/10.1007/978-3-658-14941-3_4> Bachmann, F. (2016).
% Texturbestimmung aus Beugungsbildern. In: Optimierung der Goniometrie zur 
% Texturbestimmung aus Röntgenbeugungsbildern. Springer Spektrum, Wiesbaden.
%
% See also
% PoleFigure/calcODF PoleFigureRefinement


% target resolution
% targetS3G = getClass(varargin,'SO3Grid');
if pf.allR{1}.isOption('resolution')
    targetres = min(cellfun(@(r) r.resolution,pf.allR));
else
    targetres = 5*degree;
end

targetres = get_option(varargin,'resolution',targetres);
targethw  = get_option(varargin,{'HALFWIDTH','KERNELWIDTH'},targetres,'double');

psi       = SO3DeLaValleePoussinKernel('halfwidth', ...
    get_option(varargin,{'HALFWIDTH','KERNELWIDTH'},targethw,'double'));
psi       = getClass(varargin,'SO3Kernel',psi);
targethw  = psi.halfwidth;

% ensure that halfwidth is larger than resolution
% we could choose hw = 3/2*res
targetres = min(targetres,targethw);

% parameterize kernel
psi       = @(hw) feval(class(psi),'halfwidth',hw);
nsteps    = get_option(varargin,'MaxSteps',5);
steps     = @(res) (sqrt(exp(1)).^((nsteps:-1:1)-1))*res;
hw        = steps(targethw);
res       = steps(targetres);

% remove irrelevant resolution
rm        = res>45*degree;
hw (rm)   = [];
res(rm)   = [];

format = [' %s : %s |' repmat('  %1.2f',1,pf.numPF) '\n'];

% initialized with uniform portion
odf = uniformODF(pf.CS,pf.SS);
for k=1:numel(hw)
    % discretization of ODF space
    grid = equispacedSO3Grid(pf.CS,pf.SS,'resolution',res(k));
    psik = psi(hw(k));

    % naive initial weights
    % c0 = eval(odf,grid);
    % c0 = c0./sum(c0);

    % better initial weights
    warning('off','mlsq:itermax')
    SO3F = SO3FunRBF.approximation(grid,odf.eval(grid),'kernel',psik,'mlsq','odf','nothinning');
    warning('on','mlsq:itermax')

    % adjust grid
    [grid,c0] = deal(SO3F.center,SO3F.weights);
    if ~check_option(varargin,'nothinning')
        % the default unimodalODF thinning is quite strict
        % id = weights./sum(weights(:)) > 1e-2 / psi.eval(1) / numel(weights);

        id = c0./sum(c0(:)) > min(1.0,get_option(varargin,'thinning',0.025)) / numel(c0);
        try
            grid = grid.subGrid(id);
        catch
            grid = grid(id);
        end
        c0 = c0(id);
    end

    % or use MLSSolver directly?
    [odf,alpha] = calcODF(pf,grid,psik,'c0',c0(:),'silent');

    if ~check_option(varargin,'silent') && ~getMTEXpref('generatingHelpMode')
        e = calcError(pf,odf,'silent'); % not silent :/
        fprintf(format,xnum2str(k,'fixedWidth',2), xnum2str(numel(grid),'fixedWidth',7),e);
    end

end

end