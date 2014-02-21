function M = pdfMatrix(odf,h,r,varargin)
% called by pdf 

res = get_option(varargin,'quadResolution',1*degree);

% define fibres ->  resolution x max(length(h),length(r))
ori = fibre2quat(h,r,'resolution',res).';

if check_option(varargin,'antipodal')
  ori = [ori;fibre2quat(-h,r,'resolution',res).'];
end

% find tetrahegons and compute bariocentric coordinates
[tetra,bario] = findTetra(odf.center,ori);

% get vertices of the tetrahegons -> length(ori) x 4 matrix with indices
vertices = odf.center.tetra(tetra(:),:);

% set up evaluation matrix -> resolution x max(length(h),length(r)) x
% center
% orientations
M = sparse(repmat(1:length(ori),4,1)',vertices,bario,length(ori),length(odf.center));

% take mean along fibres
M = mean(reshape(M,size(ori,1),[]));

% reshape -> max(length(h),length(r)) x length(center)
M = reshape(M,[],length(odf.center));
