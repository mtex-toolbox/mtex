function pdf = doPDF(odf,h,r,varargin)
% called by pdf 

%res = get_option(varargin,'resolution',1*degree);

% define fibres ->  max(length(h),length(r)) x resolution
ori = fibre2quat(h,r,'resolution',2*degree);

% evaluate ODF at these fibre
f = doEval(odf,ori);

% take the integral over the fibres
pdf = mean(reshape(f,size(ori)),2);
