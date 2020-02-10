function c = KLCV(ori,psi,varargin)
% Kullback Leibler cross validation for optimal kernel estimation
%
% Input
%  ori - @orientation
%  psi - @kernel
%
% Options
%  SamplingSize - number of samples
%  PartitionSize - 
%
% Output
%  c - 
%
% See also
% orientation/calcODF orientation/calcKernel orientation/BCV

% partition data set
sN = ceil(min(length(ori),get_option(varargin,'SamplingSize',1000)));
pN = get_option(varargin,'PartitionSize',ceil(1000000/length(ori)));
cN = ceil(sN / pN);

c = zeros(cN,length(psi));
iN = zeros(1,cN);
if ~check_option(varargin,'silent')
  progress(0,cN,' estimating optimal kernel halfwidth: ');
end

for i = 1:cN
  
  iN(i) = min(length(ori),i*pN);
  ind = ((i-1) * pN + 1):iN(i);
 
  d =  dot_outer(subSet(ori,ind),ori);
  
  for k = 1:length(psi)
    
    % eval kernel
    f = psi{k}.K(d) ./ length(ori) ./ numProper(ori.CS);
    
    % remove diagonal
    f(sub2ind(size(f),1:size(f,1),ind)) = 0;
    
    % sum up
    c(i,k) = sum(log(sum(f,2)));
  
    if ~check_option(varargin,'silent')
      progress((i-1)*length(psi)+k,cN*length(psi),' estimate optimal kernel halfwidth: ');
    end
  end
  
  %[cm,ci] = max(sum(c));
  %fprintf('%d ',ci);  
  
end
%fprintf('\n');

c = cumsum(c,1) ./ repmat(iN.',1,length(psi));
c = c(end,:);
%[cm,ci] = max(c);
%psi = psi(ci);

return

% some testing data

cs = crystalSymmetry('orthorhombic'); %#ok<*UNRCH>
model_odf = 0.5*uniformODF(cs,ss) + ...
  0.05*fibreODF(Miller(1,0,0,cs),xvector,'halfwidth',10*degree) + ...
  0.05*fibreODF(Miller(0,1,0,cs),yvector,'halfwidth',10*degree) + ...
  0.05*fibreODF(Miller(0,0,1,cs),zvector,'halfwidth',10*degree) + ...
  0.05*unimodalODF(axis2quat(xvector,45*degree),cs,'halfwidth',15*degree) + ...
  0.3*unimodalODF(axis2quat(yvector,65*degree),cs,'halfwidth',25*degree);

ori = calcOrientations(model_odf,1000);

for k = 1:15
  psi{k} = deLaValleePoussinKernel('halfwidth',40*degree/2^(k/4));
end
psi

c = crossCorrelation(ori,psi,'PartitionSize',10,'SamplingSize',1000);

plot(c)

[cm,ci] = max(c,[],2);

2^(-1/7)*pi^(4/7) * textureindex(model_odf,'fourier','bandwidth',32,'weighted',(1+(0:32)).*(0:32)).^(6/7)

%1000   -> 
%10000  -> 1000
%100000 -> 100
