function c = crossCorrelation(ebsd,psi,N)
% computes the cross correlation for the kernel density estimator

q = get(ebsd,'quaternion');

c = zeros(N,length(psi));
s = [];

for i = 1:N
  
  d = 2*acos(dot_outer(ebsd(1).CS,ebsd(1).SS,q(i),q([1:i-1 i+1:end])));
  
  for k = 1:length(psi)
    
    c(i,k) = log(sum(eval(psi(k),d))); %#ok<EVLC>
    
  end
  
  if mod(i,10) == 0
    %  fprintf(repmat('\b',1,length(s)));
    %  s = num2str(exp(sum(c)./i));
    %  fprintf('%s',s);
    %  %disp(c(i,:)./i);
    [cm,ci] = max(sum(c));
    fprintf('%d ',ci);
  end
    
end
fprintf('\n');

c = cumsum(c,1) ./ repmat((1:N).',1,length(psi));

return

cs = symmetry('orthorhombic');
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


crossCorrelation(ebsd,psi);


