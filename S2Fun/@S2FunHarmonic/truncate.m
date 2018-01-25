function sF = truncate(sF)
% truncate neglectable coefficients
% this includes a bit of regularisation 
% 
% Syntax
%   sF = truncate(sF)
%
% Input
%  sF - S2FunHarmonic
%
% Output
%  sF - S2FunHarmonic
%

m = 1+repelem((0:sF.bandwidth)', 2*(0:sF.bandwidth)+1, 1);
fh = abs(sF.fhat./m.^2).^2;
subs = [kron(ones(numel(sF), 1), m), kron((1:numel(sF))', ones(size(sF.fhat, 1), 1))];
fh = sqrt(accumarray(subs, fh(:)));
fh = max(fh, [], 2);
cutoff = max(fh) * 1e-8;
bandwidth = find(fh > cutoff,1,'last')-1;
if isempty(bandwidth) || ( bandwidth < 0 ), bandwidth = 0; end
sF.fhat = sF.fhat(1:(bandwidth+1)^2, :);

end
