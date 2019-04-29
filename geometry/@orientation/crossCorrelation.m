function [psi,c] = crossCorrelation(ori,varargin)
% computes the cross correlation for the kernel density estimator
%
% Input
%  ori - @orientation
%
% Options
%  kernel - a user defined @kernel
%  SamplingSize - 
%  PartitionSize - 
%
% See also
% ori/calcKernel

for k = 1:15
  psi(k) = deLaValleePoussinKernel('halfwidth',40*degree/2^(k/4)); %#ok<AGROW>
end
psi = get_option(varargin,'kernel',psi);

% partition data set
sN = ceil(min(length(ori),get_option(varargin,'SamplingSize',1000)));
pN = get_option(varargin,'PartitionSize',ceil(1000000/length(ori)));
cN = ceil(sN / pN);

c = zeros(cN,length(psi));
iN = zeros(1,cN);
progress(0,cN,' estimate optimal kernel halfwidth: ');

for i = 1:cN
  
  iN(i) = min(length(ori),i*pN);
  ind = ((i-1) * pN + 1):iN(i);
 
  d =  dot_outer(ori(ind),ori);
  
  for k = 1:length(psi)
    
    % eval kernel
    f = evalCos(psi(k),d);
    
    % remove diagonal
    f(sub2ind(size(f),1:size(f,1),ind)) = 0;
    
    % sum up
    c(i,k) = sum(log(sum(f,2)));
    
  end
  
  %[cm,ci] = max(sum(c));
  %fprintf('%d ',ci);
  progress(i,cN,' estimate optimal kernel halfwidth: ');
  
  
end
%fprintf('\n');

c = cumsum(c,1) ./ repmat(iN.',1,length(psi));
[cm,ci] = max(c(end,:));
psi = psi(ci);

return

% ----------------------------------------------------------------
% some testing data

cs = crystalSymmetry('orthorhombic'); %#ok<*UNRCH>
model_odf = 0.5*uniformODF(cs) + ...
  0.05*fibreODF(Miller(1,0,0,cs),xvector,'halfwidth',10*degree) + ...
  0.05*fibreODF(Miller(0,1,0,cs),yvector,'halfwidth',10*degree) + ...
  0.05*fibreODF(Miller(0,0,1,cs),zvector,'halfwidth',10*degree) + ...
  0.05*unimodalODF(axis2quat(xvector,45*degree),cs,'halfwidth',15*degree) + ...
  0.3*unimodalODF(axis2quat(yvector,65*degree),cs,'halfwidth',25*degree);

ori= calcOrientation(model_odf,1000);

for k = 1:15
  psi(k) = deLaValleePoussinKernel('halfwidth',40*degree/2^(k/4));
end
psi

c = crossCorrelation(ori,psi,'PartitionSize',10,'SamplingSize',1000);

plot(c)

[cm,ci] = max(c,[],2);

2^(-1/7)*pi^(4/7) * textureindex(model_odf,'fourier','bandwidth',32,'weighted',(1+(0:32)).*(0:32)).^(6/7)

%1000   -> 
%10000  -> 1000
%100000 -> 100
