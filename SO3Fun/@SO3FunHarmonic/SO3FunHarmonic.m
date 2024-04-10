classdef (InferiorClasses = {?SO3FunBingham,?SO3FunCBF,?SO3FunComposition, ...
    ?SO3FunHandle,?SO3FunHomochoric,?SO3FunRBF,?SO3FunSBF}) SO3FunHarmonic < SO3Fun
% a class representing a harmonic function on the rotational group.
%
% Syntax
%   SO3F = SO3FunHarmonic(fhat)
%   SO3F = SO3FunHarmonic(fhat,CS,SS)
%   SO3F = SO3FunHarmonic(F)
%
% Input
%  fhat  - double (harmonic coefficient vector)
%  CS,SS - @Symmetry 
%  F     - @SO3Fun 
%
% Output
%  SO3F - @SO3FunHarmonic
%
% Options
%  bandwidth - bandwidth of the harmonic expansion
%
% Example
%
%   F = SO3FunHandle(@(rot) rot.angle)
%
%   % convert into harmonic representation
%   SO3F = SO3FunHarmonic(F)
%

properties
  fhat   = [];              % harmonic coefficients
  SLeft  = specimenSymmetry % symmetry from the left
  SRight = specimenSymmetry % symmetry from the right
end

properties (Dependent=true)  
  bandwidth   % maximum harmonic degree / bandwidth
  power       % harmonic power
  antipodal
  isReal
end

methods
 
  function SO3F = SO3FunHarmonic(fhat,varargin)
    % initialize a SO(3)-valued function
    
    if nargin == 0, return;end
    
    % convert arbitrary SO3Fun to SO3FunHarmonic
    if isa(fhat,'function_handle')
      [SRight,SLeft] = extractSym(varargin);
      fhat = SO3FunHandle(fhat,SRight,SLeft);
    end
    if isa(fhat,'SO3Fun')
      f_hat = calcFourier(fhat,varargin{:});
      SO3F = SO3FunHarmonic(f_hat,fhat.SRight,fhat.SLeft,varargin{:});
      return
    end
    if isa(fhat,'SO3Kernel')
      psi = fhat;
      bw = psi.bandwidth;
      SO3F.fhat = zeros(deg2dim(bw+1),1);
      for l = 0:bw
        SO3F.fhat(deg2dim(l)+1 +(2*l+2).*(0:2*l) ) = psi.A(l+1)/sqrt(2*l+1);
      end
      return
    end
      
    % set fhat
    SO3F.fhat = fhat;
    clear fhat;
    
    % extract symmetries
    [CS,SS] = extractSym(varargin);
    SO3F.SRight = CS; SO3F.SLeft = SS;
    
    if norm(SO3F.fhat(:))==0
      SO3F.bandwidth=0;
      return
    end
    
    % extend entries to full harmonic degree
    s1 = size(SO3F.fhat,1);
    if s1>=2
      SO3F.fhat(s1+1:deg2dim(dim2deg(s1-1)+2),:)=0;
    end

    if check_option(varargin,'bandwidth')
      SO3F.bandwidth = get_option(varargin,'bandwidth');
    end

    if check_option(varargin,'antipodal')
      SO3F.antipodal = 1;
    elseif ~check_option(varargin,'skipSymmetrise')
      SO3F = SO3F.symmetrise;
    end
    
    % truncate zeros
    A = reshape(SO3F.power,size(SO3F.power,1),numel(SO3F));
    SO3F.bandwidth = max([0,find(sum(A,2) > 1e-10,1,'last')-1]);

  end
     
  function n = numArgumentsFromSubscript(varargin)
    n = 0;
  end
  
  function bandwidth = get.bandwidth(F)
    bandwidth = dim2deg(size(F.fhat,1));
  end
  
  function F = set.bandwidth(F, bw)
    newLength = deg2dim(bw+1);
    s=size(F);
    oldLength = size(F.fhat,1);
     
    if newLength > oldLength % add some zeros
      F.fhat(oldLength+1:newLength,:)=0;
    else % delete zeros
      F.fhat = F.fhat(1:newLength,:);
      F = reshape(F,s);
    end
  end
  
  function pow = get.power(F)
    
    hat = abs(F.fhat).^2;
    pow = zeros([F.bandwidth+1,size(F)]);
    for l = 0:size(pow,1)-1
      pow(l+1,:) = sum(hat(deg2dim(l)+1:deg2dim(l+1),:),1);
    end
    pow = sqrt(pow);

  end
    
  function out = get.antipodal(F)      
    if F.CS ~= F.SS
      out = false;
      return
    end
    if F.bandwidth == 0
      out = true;
      return
    end
    F = F.subSet(':');
    ind = zeros(deg2dim(F.bandwidth+1),1);
    for l = 0:F.bandwidth
      localind = reshape(deg2dim(l+1):-1:deg2dim(l)+1,2*l+1,2*l+1)';
      ind(deg2dim(l)+1:deg2dim(l+1)) = localind(:);
    end
    dd = sum(abs(F.fhat-F.fhat(ind,:)).^2);
    nF = norm(F)';
    out = all( sqrt(dd(nF>0)) ./ nF(nF>0) < 1e-4 );
  end
  
  function F = set.antipodal(F,value)
    if ~value, return; end
    ensureCompatibleSymmetries(F,'antipodal');
    F = F.symmetrise('antipodal');
  end
  
  function out = get.isReal(F)
    if F.bandwidth == 0
      out = isalmostreal(F.fhat,'precision',4);
      return
    end
    F=reshape(F,numel(F));
    ind=zeros(deg2dim(F.bandwidth+1),1);
    for l = 0:F.bandwidth
      ind(deg2dim(l)+1:deg2dim(l+1))=deg2dim(l+1):-1:deg2dim(l)+1;
    end
    dd = sum(abs(F.fhat-conj(F.fhat(ind,:))).^2);
    nF = norm(F)';
    out = all(sqrt(dd(nF>0)) ./ nF((nF>0)) <1e-4);
    % test whether fhat is symmetric fhat_nkl = conj(fhat_n-k-l)
  end
  
  function F = set.isReal(F,value)
    if ~value, return; end
    s=size(F);
    F=reshape(F,prod(s));
    ind=zeros(deg2dim(F.bandwidth+1),1);
    for l = 0:F.bandwidth
      ind(deg2dim(l)+1:deg2dim(l+1))=deg2dim(l+1):-1:deg2dim(l)+1;
    end
    F.fhat = 0.5*(F.fhat+conj(F.fhat(ind,:)));
    F=reshape(F,s);
  end
  
  function s = size(SO3F,varargin)
    s = size(SO3F.fhat);
    s = s(2:end);
    if isscalar(s), s = [s 1]; end
    if nargin > 1, s = s(varargin{1}); end
  end

  function n = numel(SO3F)
    s = size(SO3F.fhat);
    n = prod(s(2:end));
  end
  
end

methods (Static = true)
  SO3F = approximation(v, y, varargin);
  SO3F = quadrature(f, varargin);
  SO3F = adjoint(rot,values,varargin);
  SO3F = adjointNFSOFT(rot,values,varargin);
  %sF = regularisation(nodes,y,lambda,varargin);
  SO3F = WignerDmap(harmonicdegree,varargin);
  SO3F = example(varargin)
end

end
