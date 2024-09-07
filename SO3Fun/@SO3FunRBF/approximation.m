function SO3F = approximation(nodes, y, varargin)
% approximate an SO3FunRBF by given function values at given nodes
% w.r.t. some noise as described by the
%
% For $M$ given orientations $R_i$ and corresponding function values $y_i$
% we compute the SO3FunRBF $f$ which minimizes the least squares problem
%
% $$\sum_{i=1}^M|f(R_i)-y_i|^2.$$
%
% where $f$ is
%
% $$ f(R)=\sum_{j=1}^{N}w_j\psi(\omega(R_j,R)) $$
%
% with specific kernel $\psi$ centered at $N$ nodes weighted by $w_j,\sum_{j}^{N}w_{j}=1$
% as described by [1].
%
% Two routes are implemented, refered to as spatial method and harmonic method.
% The spatial method sets up a (sparse) system matrix $\Psi\in\mathbb{R}^{M\times N}$
% with entries
%
% $$ \Psi_{i,j}=\psi(\omega(R_i,R_j)) $$
%
% of the kernel values of the angle between the evaluation nodes $R_i,i=1,...,M$
% and grid nodes $R_j,j=1,...,N$.
% The harmonic method computes a system matrix $\Psi\in\mathbb{C}^{L\times M}$,
% where the columns refer to the WignerD function of each grid node $R_j$.
% Both systems are solved by a modified least squares. The spatial method
% is well suited for sharp functions (i.e. high bandwidth), whereas the
% harmonic method is better suited for low bandwidth, since the system matrix
% becomes very large for high bandwidth.
%
% If no method specific, the function will choose the best method suited
% based on some heuristics.
%
% Reference: [1] Schaeben, H., Bachmann, F. & Fundenberger, JJ. Construction of weighted crystallographic orientations capturing a given orientation density function. J Mater Sci 52, 2077–2090 (2017). https://doi.org/10.1007/s10853-016-0496-1
%
% Syntax
%   SO3F = SO3FunRBF.approximation(SO3Grid, f)
%   SO3F = SO3FunRBF.approximation(SO3Grid, f, 'resolution',5*degree)
%   SO3F = SO3FunRBF.approximation(fhat, [])
%   SO3F = SO3FunRBF.approximation(SO3Grid, f, 'kernel', psi)
%   SO3F = SO3FunRBF.approximation(SO3Grid, f, 'bandwidth', bandwidth, 'tol', TOL, 'maxit', MAXIT)
%
% Input
%  nodes   - rotational grid @SO3Grid, @orientation, @rotation or harmonic
%            coefficents
%  y       - function values on the grid (maybe multidimensional) or empty
%
% Output
%  SO3F - @SO3FunRBF
%
% Options
%  kernel           - @SO3Kernel
%  halfwidth        - use @SO3DeLaValleePoussinKernel with halfwidth
%  resolution       - resolution of the grid nodes of the @SO3Grid
%  bandwidth        - maximum degree of the Wigner-D functions used to approximate the function (Be careful by setting the bandwidth by yourself, since it may yields undersampling)
%  tol              - tolerance for mlsq
%  maxit            - maximum number of iterations for mlsq
%
% Flags
%  spatial/spm      - spatial method
%  harmonic/fourier - harmonic method
%  mlm              - maximum likelihood method?
%
% See also
% SO3Fun/interpolate SO3FunHarmonic/approximation WignerD


% Tests
% check_WignerD
% check_SO3FunRBFApproximation

if nargin < 2
    y = [];
else
    varargin = [y,varargin];
end

if check_option(varargin,'kernel')
    psi = get_option(varargin,'kernel');
elseif check_option(varargin,'halfwidth','double')
    psi = SO3DeLaValleePoussinKernel('halfwidth',get_option(varargin,'halfwidth'));
else
    psi = SO3DeLaValleePoussinKernel('halfwidth',10*degree);
end
hw = psi.halfwidth;

% extract the grid to use for the SO3FunRBF
res = get_option(varargin,'resolution',max(0.75*degree,hw));
if isa(res,'SO3Grid')
    SO3G = res;
    res = res.resolution;
else
    SO3G = extract_SO3grid(nodes,varargin{:},'resolution',res);
end

% if input is a SO3Fun, either set up an nodes/y or fourier coeff
if isa(nodes,'SO3Fun')
    if check_option(varargin,{'harmonic','fourier'}) % get_flag?
        y0 = nodes.eval(SO3G); % initial guess for coefficients
        nodes = calcFourier(nodes,'bandwidth',psi.bandwidth+1);
        y = [];
    else
        approxres = get_option(varargin,'approxresolution',res/2);
        if isa(res,'SO3Grid')
            so3approx = approxres;
        else
            so3approx = extract_SO3grid(nodes,varargin{:},...
                'resolution',get_option(varargin,'approxresolution',res/2));
        end
        y = nodes.eval(so3approx);
        nodes = so3approx;
    end
end


if isa(nodes,'orientation')
    chat = spatialMethod(SO3G,psi,nodes,y,varargin{:});
elseif isempty(y)
    chat = harmonicMethod(SO3G,psi,nodes,y0,varargin{:});
end

if check_option(varargin,{'nothinning','-nothinning'})
    SO3F = SO3FunRBF(SO3G,psi,chat);
else
    SO3F = unimodalODF(SO3G,psi,'weights',chat);
end

end

function chat = spatialMethod(SO3G,psi,nodes,y,varargin)

% vdisp([' approximation grid: ' char(SO3G)],varargin{:});

Psi = splitSummationMatrix(psi,SO3G,nodes,varargin{:});

c0 = Psi*y(:);
c0(c0<=eps) = eps;
c0 = c0./sum(c0(:));

itermax = get_option(varargin,'iter_max',100);
tol = get_option(varargin,{'tol','tolerance'},1e-3);

chat = mlsq(Psi.',y(:),c0(:),itermax,tol);

end


function chat = harmonicMethod(SO3G,psi,fhat,y0,varargin)

N = length(SO3G);

% initial guess for coefficients
if isempty(y0)
    c0 = ones(N,1)./N;
else
    c0 = y0(:) ; %odf.eval(SO3G);
    c0(c0<=eps) = eps;
    c0 = c0./sum(c0(:));
end

% get fourier coefficients for each node
Fstar = WignerD(SO3G,'kernel',psi);

% sparsify
Fstar(abs(Fstar) < 10*eps) = 0;
Fstar = sparse(Fstar);

% pad fourier coefficients if necessary
if size(fhat,1) ~= size(Fstar,1)
    fhat(size(Fstar,1)+1) = 0;
    fhat(size(Fstar,1)+1:end) = [];
end

itermax = get_option(varargin,'iter_max',100);
tol = get_option(varargin,{'tol','tolerance'},1e-3);

chat = mlsq(Fstar,fhat,c0(:),itermax,tol);

end
