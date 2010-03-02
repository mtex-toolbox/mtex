function [g0,f0] = modalorientation(odf,varargin)
% caclulate the modal orientation of the odf
%
%% Input
%  odf - @ODF 
%
%% Output
%  g0 - @orientation
%
%% See also
%

% initial resolution
res = 5*degree;

% initial seed
ori = orientation(odf(1).CS,odf(1).SS);
S3G = orientation(odf(1).CS,odf(1).SS);
for i = 1:length(odf) 
  
  switch ODF_type(odf(i).options{:})
  
    case 'UNIFORM' % uniform portion
    
    case 'FOURIER'
    
      S3G = SO3Grid(res,odf(1).CS,odf(1).SS);
          
    case'FIBRE' % fibre symmetric portion
     
      ori = [ori;orientation('fibre',...
        odf(i).center{1},odf(i).center{2},odf(1).CS,odf(1).SS,'resolution',res)]; %#ok<AGROW>
      
    case 'Bingham'
   
      ori = [ori;orientation(odf(i).center(:),odf(1).CS,odf(1).SS)]; %#ok<AGROW>
      S3G = SO3Grid(res,odf(1).CS,odf(1).SS);
       
    otherwise % radially symmetric portion
      
      center = odf(1).center(odf(1).c>=quantile(odf(1).c,-20));
      ori = [ori;center(:)]; %#ok<AGROW>
           
  end
end

% the search grid
S3G = [orientation(S3G(:)); ori];

% first evaluation
f = eval(odf,S3G,varargin{:}); %#ok<EVLC>

% extract 20 largest values
g0 = S3G(f>=quantile(f,-20));

while res > 0.25*degree

  % new grid
  S3G = [g0;orientation(SO3Grid(res/4,odf(1).CS,odf(1).SS,'max_angle',res,'center',g0))];
    
  % evaluate ODF
  f = eval(odf,S3G,varargin{:}); %#ok<EVLC>
  
  % extract largest values
  if res < 2*degree
    g0 = S3G(f>=quantile(f,-1));
  else
    g0 = S3G(f>=quantile(f,-20));
  end
  res = res / 2; 
end

[f0,i0] = max(f(:));
g0 = S3G(i0);

