function [psi,c] = crossCorrelation(ebsd,varargin)
% computes the cross correlation for the kernel density estimator


for k = 1:15
  psi(k) = kernel('de la Vallee Poussin','halfwidth',40*degree/2^(k/4)); %#ok<AGROW>
end
psi = get_option(varargin,'kernel',psi);

q = get(ebsd,'orientations');

%% partition data set
sN = ceil(min(length(q),get_option(varargin,'SamplingSize',1000)));
pN = get_option(varargin,'PartitionSize',ceil(1000000/numel(q)));
cN = ceil(sN / pN);

c = zeros(cN,length(psi));
iN = zeros(1,cN);
progress(0,cN,' estimate optimal kernel halfwidth: ');

for i = 1:cN
  
  iN(i) = min(length(q),i*pN);
  ind = ((i-1) * pN + 1):iN(i);
  
  d = dot_outer(ebsd(1).CS,ebsd(1).SS,q(ind),q);
  
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

%% some testing data

cs = symmetry('orthorhombic'); %#ok<*UNRCH>
ss = symmetry('triclinic');
model_odf = 0.5*uniformODF(cs,ss) + ...
  0.05*fibreODF(Miller(1,0,0),xvector,cs,ss,'halfwidth',10*degree) + ...
  0.05*fibreODF(Miller(0,1,0),yvector,cs,ss,'halfwidth',10*degree) + ...
  0.05*fibreODF(Miller(0,0,1),zvector,cs,ss,'halfwidth',10*degree) + ...
  0.05*unimodalODF(axis2quat(xvector,45*degree),cs,ss,'halfwidth',15*degree) + ...
  0.3*unimodalODF(axis2quat(yvector,65*degree),cs,ss,'halfwidth',25*degree);

ebsd= simulateEBSD(model_odf,1000);

for k = 1:15
  psi(k) = kernel('de la Vallee Poussin','halfwidth',40*degree/2^(k/4));
end
psi

c = crossCorrelation(ebsd,psi,'PartitionSize',10,'SamplingSize',1000);

plot(c)

[cm,ci] = max(c,[],2);

2^(-1/7)*pi^(4/7) * textureindex(model_odf,'fourier','bandwidth',32,'weighted',(1+(0:32)).*(0:32)).^(6/7)

%1000   -> 
%10000  -> 1000
%100000 -> 100
