function [  x_avg, ...
            a, a_lower, a_upper,...
            b, b_lower, b_upper ...
         ] = ...
fit_slope_of_segments_changing_with_integrated_Brownian_motion( ...
            x, y, i_select_begin, i_select_end, ...
            D, CUTOFF_eps, CUTOFF_itermax )
% fits line parameters (a,b) for consequtive segements of data (x,y),
% assuming a slow integrated Brownian motion for the slope (a).
% i_select_begin and i_select_end are integer arrays containing the
% starting and ending index of each segement in the full dataset x,y
% D is the predetermined diffusion constant of da/dt
% CUTOFF_eps is the precision tolerance for the estimate of a
% CUTOFF_itermax is the number of allowed iteration while fitting
    

% relevant averages for each region
     kmax = length(i_select_begin); 

     n_points = zeros(kmax,1);
     x_avg = zeros(kmax, 1);
     y_avg = zeros(kmax, 1);
     var_x = zeros(kmax, 1);
     yxtilde_avg = zeros(kmax,1);
     var_y = zeros(kmax,1);
     for k = 1 : kmax
         % number of points
         n_points(k) = i_select_end(k) - i_select_begin(k) + 1;

         % <x>
         x_avg(k) = mean( x( i_select_begin(k) : i_select_end(k) ) ) ;

         % <y>
         y_avg(k) = mean( y( i_select_begin(k) : i_select_end(k) ) ) ; 

         % <x^2> - <x>^2 = <(x tilde)^2> = Var(x)
         var_x(k) = var( x( i_select_begin(k) : i_select_end(k) ) ) ;

         % <y (x tilde)>
         yxtilde = y(i_select_begin(k) : i_select_end(k)) .* ...
             ( x(i_select_begin(k) : i_select_end(k)) - x_avg(k) );
         yxtilde_avg(k) = mean(yxtilde);

         % <y^2> - <y>^2 = Var(y)
         var_y(k) = var( y(i_select_begin(k) : i_select_end(k)) );
     end



     % time differences between midpoints of neighboring regions
     dx = zeros(kmax,1);
     for k = 2 : kmax
         dx(k) = x_avg(k) - x_avg(k-1);
     end

     % coupling between neighboring regions
     % ( obtained from maximum likelyhood estimate 
     %   using the integrated Brownian prior for a)
     h = zeros(kmax, kmax);

     % first row
     h(1,1) =  3/D * 1/( dx(2)^2 * (dx(3) + dx(2)) );
     h(1,2) = -3/D * 1/( dx(2)^2 * dx(3) );
     h(1,3) =  3/D * 1/( dx(2) * dx(3) * (dx(2) + dx(3)) );

     % second row
     h(2,1) = -3/D * 1/( dx(2)^2 * dx(3) );
     h(2,2) =  3/D * ( 1/( dx(2)*dx(3)^2 ) + 1/( dx(2)^2*dx(3) ) + ...
                       1/( dx(3)^2*(dx(4) + dx(3)) ) );
     h(2,3) = -3/D * 1/( dx(3)^2 ) * (1/dx(2) +  1/dx(4));
     h(2,4) =  3/D * 1/( dx(3) * dx(4) * (dx(4) + dx(3)) );

     % bulk of the matrix
     for k = 3 : kmax-2
         h(k, k-2) =  3/D * 1/( dx(k) * dx(k-1) * (dx(k) + dx(k-1)) );
         h(k, k-1) = -3/D * 1/(dx(k)^2) * ( 1/dx(k-1) + 1/dx(k+1) );
         h(k, k  ) =  3/D * ( 1/( dx(k)^2 * (dx(k) + dx(k-1)) )  + 1/( dx(k) * dx(k+1)^2 ) + ...
                           + 1/( dx(k)^2 * dx(k+1) ) + 1/( dx(k+1)^2 * (dx(k+2) + dx(k+1)) ) );
         h(k, k+1) = -3/D * 1/(dx(k+1)^2) * ( 1/dx(k) + 1/dx(k+2) );
         h(k, k+2) =  3/D * 1/( dx(k+1) * dx(k+2) * (dx(k+2) + dx(k+1)) );
     end

     % second to last row
     h(kmax-1, kmax-3) =  3/D * 1/( dx(kmax-1) * dx(kmax-2) * (dx(kmax-1) + dx(kmax-2)) );
     h(kmax-1, kmax-2) = -3/D * 1/(dx(kmax-1)^2) * ( 1/dx(kmax-2) + 1/dx(kmax) );
     h(kmax-1, kmax-1) =  3/D * ( 1/( dx(kmax-1)^2 * (dx(kmax-1) + dx(kmax-2)) ) + ...
                             1/( dx(kmax-1) * dx(kmax)^2 ) + 1/( dx(kmax-1)^2 * dx(kmax) ) );
     h(kmax-1, kmax  ) = -3/D * 1/( dx(kmax)^2 * dx(kmax-1) );

     % last row
     h(kmax, kmax-2) =  3/D * 1/( dx(kmax) * dx(kmax-1) * (dx(kmax) + dx(kmax-1)) );
     h(kmax, kmax-1) = -3/D * 1/( dx(kmax)^2 * dx(kmax-1) );
     h(kmax, kmax  ) =  3/D * 1/( dx(kmax)^2 * (dx(kmax) + dx(kmax-1)) );


     % fitting the function y(x) = b + a(x - <x>) + Gaussian noise 
     % on each region separately to get a starting point
     a = yxtilde_avg ./ var_x;
     b = y_avg;
     sigmasq = var_y - ( yxtilde_avg.^2 ./ var_x );

     % iteratively solving the full fitting equation
     % M[D,sigmasq] * a = v[D,sigmasq]
     % where sigmasq is expressed with values of a from previous iteration
     a_new = zeros(kmax,1);
     i = 1;
     progressbar = waitbar(0,'Fitting. Please wait...');
     while i < CUTOFF_itermax
        % setting up the system of equations
        % RHS vector
        v = n_points .* yxtilde_avg ./ sigmasq ;

        % LHS matrix
        % mass coefficients of each region
        mass = n_points .* var_x ./ sigmasq ;
        % adding the couplings
        M = diag(mass) + h;

        % solving for the new a values
        a_new = linsolve(M,v);
        if max( abs(a_new - a) ./ a ) < CUTOFF_eps
            i = CUTOFF_itermax;
        end

        % updating
        a = a_new;
        sigmasq = var_y - 2 * a .* yxtilde_avg + a.^2 .* var_x;
        
        waitbar(i/CUTOFF_itermax);
        i = i + 1;
     end
     close(progressbar);   


     % Confidence intervals

     % setting up the inverse covariance matrix for (a and sigmasq)
     mass = n_points .* var_x ./ sigmasq;
     M = diag(mass) + h;
    
     % upper left block
     Covinv = blkdiag(M, zeros(kmax,kmax));

     for k = 1 : kmax
         % lower left block
         Covinv(kmax + k, k) = - n_points(k) / (sigmasq(k)^2) * ( a(k) * var_x(k) - yxtilde_avg(k) );
         % upper right block
         Covinv(k, kmax + k) = - n_points(k) / (sigmasq(k)^2) * ( a(k) * var_x(k) - yxtilde_avg(k) );
         % lower right block
         Covinv(kmax + k, kmax + k) = ...
             n_points(k) / (2* sigmasq(k)^2) * ...
                ( -1 + 1/(2*sigmasq(k)) *( var_y(k) - 2*a(k)*yxtilde_avg(k) + a(k)^2*var_x(k) ) );
     end

     % inverting to get the covariance matrix of a and sigmasq
     Cov = inv(Covinv);


     % stdev for the fitted parameters (ie. a, b, sigmasq)
     std_a = zeros(kmax,1);
     std_b = zeros(kmax,1);
     std_sigmasq = zeros(kmax,1);
     for k = 1 : kmax
         std_a(k) = sqrt(Cov(k,k));
         std_b(k) = sqrt( sigmasq(k) / n_points(k) );   % the covariance for b is diagonal and independent of the cov. of a and sigmasq
         std_sigmasq(k) = sqrt( Cov(kmax + k, kmax + k) );
     end

     % confidence intervals for fitted parameters
     a_lower = zeros(kmax,1);
     a_upper = zeros(kmax,1);
     b_lower = zeros(kmax,1);
     b_upper = zeros(kmax,1);
     sigmasq_lower = zeros(kmax,1);
     sigmasq_upper = zeros(kmax,1);
     for k = 1 : kmax
         a_lower(k) = a(k) -  std_a(k);
         a_upper(k) = a(k) +  std_a(k);
         b_lower(k) = b(k) -  std_b(k);
         b_upper(k) = b(k) +  std_b(k);
         sigmasq_lower(k) = sigmasq(k) -  std_sigmasq(k);
         sigmasq_upper(k) = sigmasq(k) +  std_sigmasq(k);
     end
