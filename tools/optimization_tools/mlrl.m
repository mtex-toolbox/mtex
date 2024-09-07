function [chat,k] = mlrl(Psi,I,c0,itermax,tol)
% maximum likelihood estimate for Psi*c = I, sum(c) = 1, I>0, c>0 with richard-lucy iteration
%
% Input
%   Psi     - system matrix (N x M)
%   I       - intensities (N x 1)
%   c0      - initial coefficients (M x 1), real valued
%   itermax - maximum number of iterations
%   tol     - abort if change smaller than tolerance


if nargin < 5
    tol = 1/size(Psi,2)^2;
end

if nargin < 4
    itermax = 100;
end

if nargin < 3 
    M = size(Psi,2);
    c0 = ones(M,1)./M;
end

if any(I(:)<0)
    error('ml:ensureNonNegative','The intensities must be non-negative.');
end

[oldc,chat] = deal(c0,c0);
Is = sum(I(:));

for k=1:itermax
    %richard lucy iteration
    %gradient direction
    chat = chat.*((I./(Psi*chat)).'*Psi).'./Is;
    chat(~isfinite(chat)) = 0;

    r = oldc-chat; % residuals
    if r'*r < tol 
        break
    end
    oldc = chat;
end
end

