classdef infimalConvolutionFilter < EBSDFilter
  % matrix-valued image with the TV-norm.
  % \argmin_u{\|u-u_0\|_2^2 + \lambda \|\nabla u\|_{2,1} + \mu \|H u\|_{2,1}},
  % \lambda,\mu > 0
  % Written by Johannes Persch, Ronny Bergmann, 09.06.2015
  % function ma_val_im_reg_2nd_ord minimzes the second order model of a
  % OUTPUT:
  %  u_hat:       computed minimizer
  %  diff:        differences of u and v between two successive iterations
  %
  % 12.05.15 by Markus Loeckel
  % 25.05.15 substituted gauss seidel by mldivide
  % 26.05.15 modified SPD by not deleting half of the entries
  % 30.06.15 projection onto sphere added
  % 01.07.15 mask added
  % 14.07.15 alternative minimzation w.r.t. u via preconditioned cg added
  % 16.07.15 first-and second-order combined
  % 16.07.15 stopping criterion added
  
  properties
    lambda = 0.005 % first-order regularization parameter [0,1]
    mu = 0.01      % second-order regularization parameter [0,1]
    gamma = 1      % parameter of the augmented lagrangian, >0
    maxit = 50     % maximum number of iterations
    eps_rel = 1e-5
    tol_CG = 1e-3  %tolerance for CG method
    method = 'CG'
  end
  
  methods
    
    function F = infimalConvolutionFilter(varargin)
      
      addlistener(F,'isHex','PostSet',@check);
      function check(varargin)
        if F.isHex
        warning(['Hexagonal grids are not yet fully supportet for the infimalConvolutionFilter. ' ...
          'It might give reasonable results anyway']);
        end
      end
      
    end
    
    function ori = smooth(F,ori,varargin)
      %
      % Input:
      %    F: @EBSDFilter
      %  ori: @orientation
      %
      % Output:
      %  ori: @orientation

      
      [M,N] = size(ori);

      
      [qmean,q] = mean(ori);
      q = quaternion(q);
      %u_0 = double(log(q,quaternion(qmean)));
      
      %u_0 = double(ori);
      u_0 = double(q);

      dim = size(u_0,3);
      mask = repmat(~ori.isnan,1,1,dim);
      
      % computing the matrix nabla
      DM = spdiags([-ones(M,1), ones(M,1)],[0,1],M,M);
      DM(end,end)=0;
      DN = spdiags([-ones(N,1), ones(N,1)],[0,1],N,N);
      DN(end,end)=0;

      DX = kron(DN, speye(M));
      DY = kron(speye(N),DM);
      mm = ~mask(1:M*N);
      DX(any(DX(:,mm),2),:) = 0;
      DY(any(DY(:,mm),2),:) = 0;

      L = [DX;DY];  % discrete gradient in both directions

      % computing the Hessian operator
      DM = spdiags([-ones(M,1), ones(M,1)],[0,1],M,M);
      DM(end,end)=0;
      DN = spdiags([-ones(N,1), ones(N,1)],[0,1],N,N);
      DN(end,end)=0;

      DNtDN = DN'*DN;
      DNtDN([1,end],:) = 0;
      DMtDM = DM'*DM;
      DMtDM([1,end],:) = 0;
      DXX = -kron(DNtDN,speye(M));
      %DXY = -kron(DN,DM');
      %DYX = -kron(DN',DM);
      DYY = -kron(speye(N),DMtDM);
      clear DNtDN
      clear DMtDM

      mm = ~mask(1:M*N);
      DXX(any(DXX(:,mm),2),:) = 0;
      DYY(any(DYY(:,mm),2),:) = 0;
      H = [DXX;DYY];
            
      % initialization
      u_0 = reshape(u_0,M*N,dim);
      mask = reshape(mask,M*N,dim);
      u_sav = u_0;
      u_0(~mask) = 0;
      u = u_0;
      v = 0.5*u_0;
      w = 0.5*u_0;
      vw = [v;w];
      vt = 0.5*L*u_0;
      wt = 0.5*H*u_0;
      p = u;        % first Lagrange multiplier
      q = vt;       % second Lagrange multiplier
      r = wt;       % third Lagrange multiplier
      
      I = speye(M*N);
      Im = I*spdiags(mask(1:M*N)',0,M*N,M*N);
      L2 = L'*L;
      H2 = H'*H;
      
      if strcmp(F.method,'CG')
        %A = (2+F.gamma)*I+F.gamma*(L2+H2);                 % coefficiency matrix
        A = [2*Im+F.gamma*I+F.gamma*L2 2*Im+F.gamma*I; ...
          2*Im+F.gamma*I          2*Im+F.gamma*I+F.gamma*H2];
        C = spdiags(ones(2*M*N,1)./spdiags(A,0),0,2*M*N,2*M*N);     % preconditioner
      else
        A = [2*Im+F.gamma*I+F.gamma*L2 2*Im+F.gamma*I; ...
          2*Im+F.gamma*I          2*Im+F.gamma*I+F.gamma*H2];
      end
      
      diff = zeros(1,F.maxit+1);
      
      iteration = 1;
      diff(1) = inf;
      
      while iteration <= F.maxit
        
        % save old iterates
        v_old = v;
        w_old = w;
                
        % minimization w.r.t. u via CG or mldivide
        
        if strcmp(F.method,'CG')
          B = [2*u_0+F.gamma*u-p+L'*(F.gamma*vt-q); 2*u_0+F.gamma*u-p+H'*(F.gamma*wt-r)];
          R = B - A*[v; w];
          G = C*R;
          D = G;
          RG_dot = dot(R,G);
          while max(sqrt(sum(R.^2,1))) >= F.tol_CG
            Z = A*D;
            alpha = repmat(RG_dot./dot(D,Z),2*M*N,1);
            vw = vw + alpha .* D;
            R = R - alpha .* Z;
            G = C * R;
            RG_dot_old = RG_dot;
            RG_dot = dot(R,G);
            beta = repmat(RG_dot./RG_dot_old,2*M*N,1);
            D = G + beta .* D;
          end
        else
          vw = mldivide(A,  [2*u_0+F.gamma*u-p+L'*(F.gamma*vt-q); 2*u_0+F.gamma*u-p+H'*(F.gamma*wt-r)]);
        end
        
        %vw(~mask) = 0;
        v = vw(1:end/2,:);
        w = vw(end/2+1:end,:);
        %v(~mask) = 0;
        %w(~mask) = 0;
        
        % minimization w.r.t. v
        
        %u = v+w + 1/F.gamma * p;
        u = projection_sphere(v+w + 1/F.gamma * p);
        
        % minimization w.r.t. w
        
        b = L * v + 1/F.gamma * q;        % helper variable
        b_norm = sqrt(sum(b.^2,2));
        
        vt = repmat(max(b_norm-F.lambda/F.gamma,0)./b_norm,1,dim) .* b;
        vt(isnan(vt)) = 0;                % set to zero if it was divided by zero
        
        
        % minimization w.r.t. x
        
        b = H * w + 1/F.gamma * r;        % helper variable
        b_norm = sqrt(sum(b.^2,2));
        
        wt = repmat(max(b_norm-F.mu/F.gamma,0)./b_norm,1,dim) .* b;
        wt(isnan(wt)) = 0;                % set to zero if it was divided by zero
        
        
        % update of Lagrange multipliers
        
        p = p + F.gamma * ((v+w) - u);
        q = q + F.gamma * (L * v - vt);
        r = r + F.gamma * (H * w - wt);
        
        iteration = iteration + 1;
        diff(iteration) = sum(([w(:);v(:)]-[w_old(:);v_old(:)]).^2);
       
      end
      
      diff(1) = [];
      diff(iteration:end) = [];
      
      u(~mask) = u_sav(~mask);
      u_hat = reshape(u,M,N,dim);
      
      %ori = orientation(expquat(vector3d(u_hat(:,:,1),u_hat(:,:,2),u_hat(:,:,3)),quaternion(qmean)),ori.CS,ori.SS);
      
      ori.a = u_hat(:,:,1);
      ori.b = u_hat(:,:,2);
      ori.c = u_hat(:,:,3);
      ori.d = u_hat(:,:,4);
      
      function v = projection_sphere(u)
        % function projections_sphere projects the rows of a given matrix u onto
        % the sphere. u is the M*N x m matrix, where every row consists of values
        % that will be projected onto S^m.
        %

        [~,n] = size(u);
        u_sum = sqrt(sum(u.^2,2));
        v = u./repmat(u_sum,1,n);
        v(isnan(v(:,1))) = 1; % zero vectors are projected to [1 0 ... 0]
        v(isnan(v)) = 0;
      end

    end
  end
end