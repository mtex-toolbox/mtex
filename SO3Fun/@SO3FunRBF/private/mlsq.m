function [chat,k] = mlsq(Psi,I,c0,itermax,tol)
% modified least squares, sum(c0) =1, c0>0
%
% Input
%   Psi     - system matrix
%   I       - intensities
%   c0      - initial coefficients for each kernel
%   itermax - maximum number of iterations
%   tol     - abort if change smaller than tolerance

chat = c0;
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
    taub = max(min(taub,taumax),0);

    % update coeffients
    chat = chat - taub*ctilde;

    % update residuals
    r = r-taub*rtilde; % r = Psi*chat-I;

    % compute error
    newErr = norm(r);
    if oldErr-newErr < tol
        break; % abort if change to small (or getting worse)
    end
    oldErr = newErr;
end
end
