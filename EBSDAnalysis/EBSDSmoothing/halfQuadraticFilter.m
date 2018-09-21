classdef halfQuadraticFilter < EBSDFilter
  % haldQuadraticFilter uses the techniques elaborated half-quadratic
  % minmization on manifolds
  % to smooth EBSD data.
  % Properties:   alpha:  regularisation parameter in [x,y] direction
  %               weight: function handle specified by the regularising
  %                       function \varphi, @(t,eps), where eps is its
  %                       parameter
  %               eps:    Parameter for the weight
  %               tol:    Tolerance for the gradient descent
  %               threshold: threshold for subgrain boundaries
  % Methods:      smooth: Applies the HQ minimization on the quaternions
  %                       of the given orientations
  %
  % For further details of the algorithm see:
  % R. Bergmann, R. H. Chan, R. Hielscher, J. Persch, G. Steidl
  % Restoration of Manifold-Valued Images by Half-Quadratic Minimization.
  % Preprint, ArXiv #1505.07029. (2015)
  %
  %
  % Written by Johannes Persch, Ronny Bergmann, 09.06.2015
  %        <persch@mathematik.uni-kl.de>, <bergmann@mathematik.uni-kl.de>
  
  % Should be included in the function call or the filter class
  % uM is the unknown mask, i.e masking the pixels we want to
  %                           inpaint
  % dM is the domain of the image, pixels which are relevant
  %           for the calculation
  % rM is where we change the pixel values
  properties
    alpha = [0.1,0.1];                      % regularization in x, y direction
    weight = @(t,eps,th) (t<=th)./(t.^2+eps^2).^(1/2); % weight function handle b^*(t,epsilon)
    eps = 1e-2;                             % parameter for the weight function
    tol = 1e-5                              % tolerance for gradient descent
    threshold = 5*degree                    % threshold for subgrain boundaries
  end
  
  methods
    
    function ori = smooth(F,ori)
      % INPUT:    ori:   n x m vector of crystal orientations
      %           F:     Class with specified parameters for the HQ
      %                  minimization
      % OUTPUT:   ori:   n x m vector of crystal orientations
      %                  smoothed by HQ minimzation using the
      %                  parameters specified in F
      % Written by Johannes Persch, Ronny Bergmann, 09.06.2015     

      % this might be done better
      [~,q] = mean(ori);
      dims =size(q);
      % pass the masks for readablity
      %Logical mask Defaults
      rM = false(dims);             % [1] Pixel is fixed
      % [0] Pixel is changed
      % should be [1] outside the respective grain and at pixels we want to
      % preserve
      
      uM = false(dims);             % [1] Pixel is unknown
      % [0] Pixel is known if it isnt NaN
      
      dM = true(dims);              % [1] Pixel matters in the calculation
      % [0] Pixel is excluded from calculation
      % should be [0] outside the grain
      
      % Security check
      if length(F.alpha)<2, F.alpha = F.alpha*[1,1]; end
      u=q;
      % Start inpaiting
      if any(isnan(q.a(:))) || any(uM(:))
        % Collapse manifold dimensions
        uM = uM | (isnan(q.a));
        % Set all unknowns to nan in u
        u(uM) = quaternion.nan;
        % Remember Pixels outside the domain
        outside =  u;
        while any(~(~isnan(u(:).a) | ~dM(:)))
          % Set pixels Outside the domain to NaN, since they should
          % not be used for the initialisation
          u(~dM) = quaternion.nan;
          % Collect the neighborhood of each pixel
          B = reshape(cat(3,u,u([2:end end],:),u(:,[2:end end]),u([1 1:end-1],:),u(:,[1 1:end-1])),[prod(dims),5]);
          setVals = sum(isnan(B(:,2:5).a),2)<4 ...
            & isnan(u(:).a);
          % Exclude Pixels outside the Domain
          setVals = setVals & dM(:);
          ut = B(setVals,:); % collect all points that can be initialized in this step
          for j=1:size(ut,1)
            points = ut(j,~any(isnan(ut(j,:).a),1)); %Collect existing neighbor points
            ut(j,1) = points(:,1); % first nonnan neighbor.
          end
          u = reshape(u,[1,prod(dims)]);
          u(setVals) = ut(:,1); % set new values
          u = reshape(u,dims);
        end
        % Readjust values outside the domain
        u( ~dM) = outside(~dM);
        % NaN values outside the domain (the only oney remaining)
        % are set to the identity
        u(isnan(u.a)) = quaternion.id;
      end
      
      u_old = u;
      entrance = true;
            
      i = 1;
      while i < 100 && max(max(angle(u_old,u)))>F.tol || entrance
        u_old = u;
        entrance = false;
        % Calculate weight
        wx = F.weight(angle(u,u([2:end end],:)),F.eps,F.threshold);
        % Exclude pixels which are not in the Domain
        wx(  ~dM | ~dM([2:end end],:)  ) = 0;
        wy = F.weight(angle(u,u(:,[2:end end],:)),F.eps,F.threshold);
        wy(  ~dM | ~dM(:,[2:end end],:)  ) = 0;
        wxd =F.weight(angle(u,u([1 1:(end-1)],:)),F.eps,F.threshold);
        wxd(  ~dM | ~dM([1 1:(end-1)],:)  ) = 0;
        wyd =F.weight(angle(u,u(:,[1 1:(end-1)])),F.eps,F.threshold);
        wyd(  ~dM | ~dM(:,[1 1:(end-1)])  ) = 0;
        %wxd = zeros(size(wxd));
        %wyd = zeros(size(wyd));
        
        q(uM)=u(uM);% Unknown pixel are not relevent in the data term log(x,x) =0;
        %calculate gradient
        grad_u = log(q,u) + F.alpha(1)*wx.*log(u([2:end end],:),u) + ...
          F.alpha(2)*wy.*log(u(:,[2:end end],:),u)+F.alpha(1)*wxd.*log(u([1 1:(end-1)],:),u) + ...
          F.alpha(2)*wyd.*log(u(:,[1 1:(end-1)]),u);
        % Step length
        %mult  = min(1./(~uM+F.alpha(1)*(wx+wxd)+F.alpha(2)*(wy+wyd)),1);
        mult  = min(1./(~uM+F.alpha(1)*(wx+wxd)+F.alpha(2)*(wy+wyd)),1/log(i+1));
        near_newton = mult.*grad_u;
        % Only change pixels we want to be changed
        near_newton(rM) = vector3d([0,0,0]);
        %one step
        u = expquat(near_newton,u);
        i = i+1;
      end
      
      ori = orientation(u,ori.CS,ori.SS);
    end
  end
end