function [odf,resvec] = interp(ori,values,varargin)
% compute an ODF by interpolating orientations and weights
%
% Syntax
%
%   odf = ODF.interp(ori,values)
%
% Input
%  ori - @orientation
%  values - double
% 
% Output
%  odf - @ODF
%

% construct the uniform portion first
values = values(:);
m = min(values);
values = values - m;

odf = m * uniformODF(ori.CS,ori.SS);

% grid for representing the ODF
res = get_option(varargin,'resolution',3*degree);
S3G = equispacedSO3Grid(ori.CS,ori.SS,'resolution',res);

% kernel for representing the ODF
psi = get_option(varargin,'kernel',deLaValleePoussinKernel('halfwidth',res));

% system matrix
M = psi.K_symmetrised(S3G,ori,ori.CS,ori.SS);

[w,flag,relres,iter,resvec] = lsqr(M',values,1e-2,30);

% err = abs(M'*w - values);
% disp(['   maximum error during interpolating ODF: ',xnum2str(max(err))]);
% disp(['   mean error during interpolating ODF   : ',xnum2str(mean(err))]);

odf = odf + (1-m).*unimodalODF(S3G,psi,'weights',w./sum(w));

end