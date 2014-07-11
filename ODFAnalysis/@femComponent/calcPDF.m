function pdf = calcPDF(component,h,r,varargin)
% called by pdf 

%res = get_option(varargin,'resolution',1*degree);

% define fibres ->  max(length(h),length(r)) x resolution
ori = fibre2quat(h,r,'resolution',2*degree);

if check_option(varargin,'antipodal')
  
  ori = [ori,fibre2quat(-h,r,'resolution',2*degree)];
  
end

% evaluate ODF at these fibre
f = eval(component,ori);

% take the integral over the fibres
pdf = mean(reshape(f,size(ori)),2);
