classdef halfQuadraticFilter < EBSDFilter
  
  properties
    alpha = [0.1,0.1];                      % regularization in x, y direction
    weight = @(t,eps) 1./(t.^2+eps^2).^(1/2); % weight function handle b^*(t,epsilon)
    eps = 1e-1;                             % parameter for the weight function
    tol = 1e-5                              % tolerance for gradient descent  
  end

  methods
    
    function q = smooth(F,q)           
      % Johannes Persch 09.06.2015
      
      q = sign(q.a) .* q;
      M = qSO3;

      static_mask = isnan(q.a); % logical mask with true for stationary pixels
      
      dims =size(q);
      
      if length(F.alpha)<2, F.alpha = F.alpha*[1,1]; end
      
      n_2 = dims(end);
      n_1 = dims(end-1);
      mani_dims = dims(1:end-2);
      mask = isnan(q.a);
      u=q;
      col_u = reshape(u,[prod(mani_dims),n_1,n_2]);
      ux =col_u;
      uy = col_u;
      ux(:,1:end-1,:) = col_u(:,2:end,:);
      ux(:,end,:)=col_u(:,end,:);
      uy(:,:,1:end-1) = col_u(:,:,2:end);
      uy(:,:,end)=col_u(:,:,end);
      %Auxillary
      uxd =col_u;
      uyd= col_u;
      uxd(:,2:end,:) = col_u(:,1:end-1,:);
      uxd(:,1,:)=col_u(:,1,:);
      uyd(:,:,2:end) = col_u(:,:,1:end-1);
      uyd(:,:,1)=col_u(:,:,1);
      

      %Initialisiere u
      B = repmat(u,[ones(1,length(dims)),5]);
      B = reshape(B,prod(mani_dims),n_1*n_2,5);
      B(:,:,2) = reshape(ux,prod(mani_dims),n_1*n_2);
      B(:,:,3) = reshape(uy,prod(mani_dims),n_1*n_2);
      B(:,:,4) = reshape(uxd,prod(mani_dims),n_1*n_2);
      B(:,:,5) = reshape(uyd,prod(mani_dims),n_1*n_2);
      while sum(any(isnan(squeeze(B(:,:,1).a)),1)) > 0
        setzen = sum(squeeze(any(isnan(B(:,:,2:5).a),1)),2)<4 & any(isnan(squeeze(B(:,:,1).a)),1)';
        B(:,setzen,1) = setzen_mit_karcher(B(:,setzen,:));
        col_u = reshape(B(:,:,1),[ prod(mani_dims),n_1,n_2]);
        ux =col_u;
        uy = col_u;
        ux(:,1:end-1,:) = col_u(:,2:end,:);
        ux(:,end,:)=col_u(:,end,:);
        uy(:,:,1:end-1) = col_u(:,:,2:end);
        uy(:,:,end)=col_u(:,:,end);
        %Auxillary
        uxd =col_u;
        uyd= col_u;
        uxd(:,2:end,:) = col_u(:,1:end-1,:);
        uxd(:,1,:)=col_u(:,1,:);
        uyd(:,:,2:end) = col_u(:,:,1:end-1);
        uyd(:,:,1)=col_u(:,:,1);
        B(:,:,2) = reshape(ux,prod(mani_dims),n_1*n_2);
        B(:,:,3) = reshape(uy,prod(mani_dims),n_1*n_2);
        B(:,:,4) = reshape(uxd,prod(mani_dims),n_1*n_2);
        B(:,:,5) = reshape(uyd,prod(mani_dims),n_1*n_2);
      end
      
      u = reshape(col_u,dims);
      ux = reshape(ux,dims);
      uy = reshape(uy,dims);
      uxd = reshape(uxd,dims);
      uyd = reshape(uyd,dims);
      
      %Nullen?
      maskx_zero = squeeze(ux.a==1 & ux.b ==0);
      masky_zero = squeeze(uy.a==1 & uy.b ==0);
      maskxd_zero = squeeze(uxd.a==1 & uxd.b ==0);
      maskyd_zero = squeeze(uyd.a==1 & uyd.b ==0);
      %
      u_old = u;
      entrance = true;
      i =0;
      
      while max(max(M.dist(u_old,u)))>F.tol || entrance
        if mod(i,50)==0
          disp(['Step length at step ',num2str(i),' is ',num2str(max(max(M.dist(u_old,u))))])
        end
        
        u_old = u;
        entrance = false;
        i = i+1;
        wx = F.weight(M.dist(u,ux),F.eps);
        wy = F.weight(M.dist(u,uy),F.eps);
        wxd =F.weight(M.dist(u,uxd),F.eps);
        wyd =F.weight(M.dist(u,uyd),F.eps);
        %Nullen streichen
        wx(maskx_zero)=0;
        wy(masky_zero)=0;
        wyd(maskyd_zero)=0;
        wxd(maskxd_zero)=0;
        %
        wx = reshape(wx,n_1,n_2);
        wx = repmat(wx,[1,1,mani_dims]);
        wx = permute(wx,[3:2+length(mani_dims),1,2]);
        wxd = reshape(wxd,n_1,n_2);
        wxd = repmat(wxd,[1,1,mani_dims]);
        wxd = permute(wxd,[3:2+length(mani_dims),1,2]);
        wy = reshape(wy,n_1,n_2);
        wy = repmat(wy,[1,1,mani_dims]);
        wy = permute(wy,[3:2+length(mani_dims),1,2]);
        wyd = reshape(wyd,n_1,n_2);
        wyd = repmat(wyd,[1,1,mani_dims]);
        wyd = permute(wyd,[3:2+length(mani_dims),1,2]);
        q(mask)=u(mask);
        %berechne gradient
        grad_u = M.log(u,q) + F.alpha(1)*wx.*M.log(u,ux) + ...
          F.alpha(2)*wy.*M.log(u,uy)+F.alpha(1)*wxd.*M.log(u,uxd) + ...
          F.alpha(2)*wyd.*M.log(u,uyd);
        grad_u(static_mask) = vector3d([0,0,0]);
        mult  = min(1./(~mask+F.alpha(1)*(wx+wxd)+F.alpha(2)*(wy+wyd)),1);
        near_newton = mult.*grad_u;
        near_newton(static_mask) = vector3d([0,0,0]);
        %gehe einen Schritt
        u = M.exp(u,near_newton);
        col_u = reshape(u,[prod(mani_dims),n_1,n_2]);
        ux = col_u;
        uy = col_u;
        ux(:,1:end-1,:) = col_u(:,2:end,:);
        ux(:,end,:)=col_u(:,end,:);
        uy(:,:,1:end-1) = col_u(:,:,2:end);
        uy(:,:,end) = col_u(:,:,end);
        %Auxillary
        uxd = col_u;
        uyd = col_u;
        uxd(:,2:end,:) = col_u(:,1:end-1,:);
        uxd(:,1,:) = col_u(:,1,:);
        uyd(:,:,2:end) = col_u(:,:,1:end-1);
        uyd(:,:,1) = col_u(:,:,1);
        ux = reshape(ux,dims);
        uy = reshape(uy,dims);
        uxd = reshape(uxd,dims);
        uyd = reshape(uyd,dims);
      end
      
      disp(['Stopped after ', num2str(i) ,' iterations with last step length ',num2str(max(max(M.dist(u_old,u))))])
      q=u;
      
      function u = setzen_mit_karcher(U)
        %Find the initial values for the first layer of U as means of the
        %surrounding values
        [p_m,nr_points,~] = size(U);
        u = reshape(U(:,:,1),p_m,nr_points);
        for j= 1:nr_points
          if sum(sum(~squeeze(any(isnan(U(:,j,:).a),1)),2)) == 1
            u(:,j)= U(:,j,~isnan(U(1,j,:).a));
          else
            points = squeeze(U(:,j,~isnan(U(1,j,:).a)));
            points = points(~(points.a==1 & points.b==0));
            if size(points,1) ~=0
              u(:,j) = points(ceil(rand*length(points)));% could be fixed to eg 1
            end
          end
        end
      end      
    end
  end
end
  