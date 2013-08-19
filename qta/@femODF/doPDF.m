function pdf = doPDF(odf,h,r,varargin)
% called by pdf 

% define fibres ->  resolution x max(length(h),length(r)) 
% TODO
ori = fibre2quat(h,r,'resolution',1*degree);

% evaluate ODF at these fibre
f = doEval(odf,ori);

% take the integral over the fibres
pdf = mean(reshape(f,size(ori)));
