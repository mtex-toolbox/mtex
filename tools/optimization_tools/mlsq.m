function [chat,k] = mlsq(Psi,I,c0,itermax,tol)
% modified least squares, Psi*c = I, sum(c) = const., c>0
%
% Syntax
%  c = mlsq(Psi,I)
%  c = mlsq(Psi,I,c0)
%  [c,k] = mlsq(Psi,I,c0,itermax,tol)
%
% Input
%   Psi     - system matrix (N x M), can be complex
%   I       - intensities (N x 1), can be complex
%   c0      - initial coefficients (M x 1), real valued
%   itermax - maximum number of iterations
%   tol     - abort if change smaller than tolerance
%
% Output
%   c - coefficients (Mx1), real valued
%   k - number of iterations
%

if nargin < 5
    tol = 1-5;
end

if nargin < 4
    itermax = 100;
end

if nargin < 3
    M = size(Psi,2);
    c0 = ones(M,1)./M;
end

if any(I < 0) && any(0 < I)
    error('mlsq:ensureNonNegative','All intensities must be non-negative or negative. Mixed intensities, mixed results.');
end

chat = real(c0);
r = Psi*chat-I;     % initial residual
oldErr = Inf;
for k=1:itermax
    gradient =  r'*Psi;
    lambda = real(gradient - gradient*chat); % imaginary part should be numerical error
    % estimate coefficients
    ctilde = lambda(:).*chat;

    % estimate step size
    taumax = 1./max(abs(lambda));
    rtilde = Psi*ctilde;
    taub = real((rtilde'*r)./(rtilde'*rtilde));
    taub = sign(taub)*max(min(abs(taub),taumax),0);

    % update residuals
    r = r-taub*rtilde; % r = Psi*chat-I;

    % compute error
    newErr = norm(r);
    if oldErr-newErr < tol
        break; % abort if change to small (or getting worse)
    end
    % update coeffients if new error is smaller
    chat = real(chat - taub*ctilde);
    oldErr = newErr;
end

if k == itermax
    warning('mlsq:itermax','Maximum number of iterations reached, result may not have converged to the optimum yet.');
end


end
