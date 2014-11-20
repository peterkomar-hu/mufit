function [  x_avg, ...
            a, a_lower, a_upper,...
            b, b_lower, b_upper ...
         ] = ...
fit_slope_of_segments_changing_with_Brownian_motion( ...
            x, y, i_select_begin, i_select_end, ...
            D, CUTOFF_eps, CUTOFF_itermax )
% fits line parameters (a,b) for consequtive segements of data (x,y),
% assuming a slow Brownian motion for the slope (a).
% i_select_begin and i_select_end are integer arrays containing the
% starting and ending index of each segement in the full dataset x,y
% D is the predetermined diffusion constant
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
         % number of points in each segment
         n_points(k) = i_select_end(k) - i_select_begin(k) + 1;

         % <x> in each segment
         x_avg(k) = mean( x( i_select_begin(k) : i_select_end(k) ) ) ;

         % <y> in each segment
         y_avg(k) = mean( y( i_select_begin(k) : i_select_end(k) ) ) ; 

         % <x^2> - <x>^2 = <(x tilde)^2> = Var(x) in each segment
         var_x(k) = var( x( i_select_begin(k) : i_select_end(k) ) ) ;

         % <y (x tilde)> in each segment
         yxtilde = y(i_select_begin(k) : i_select_end(k)) .* ...
             ( x(i_select_begin(k) : i_select_end(k)) - x_avg(k) );
         yxtilde_avg(k) = mean(yxtilde);

         % <y^2> - <y>^2 = Var(y) in each segment
         var_y(k) = var( y(i_select_begin(k) : i_select_end(k)) );
     end


     % fitting the function y(x) = b + a(x - <x>) + Gaussian noise 
     % on each region separately to get a starting point
     a = yxtilde_avg ./ var_x;
     b = y_avg;
     sigmasq = var_y - ( yxtilde_avg.^2 ./ var_x );

     % constant couplings between neighboring regions
     coupling = zeros(kmax, 1);
     for k = 2 : kmax
         % for Brownian motion prior
         coupling(k) = 1 / (D * (x_avg(k) - x_avg(k-1)));
     end


     % iteratively solving the full fitting equation
     % M[D,sigmasq] * a = v[D,sigmasq]
     % where sigmasq is expressed with values of a from previous iteration
     a_new = zeros(kmax,1);
     i = 1;
     progressbar = waitbar(0,'Fitting. Please wait...');
     while i < CUTOFF_itermax
        % setting up the system of equations
        % RHS
        v = n_points .* yxtilde_avg ./ sigmasq ;

        % LHS matrix
        % mass coefficients of each region
        mass = n_points .* var_x ./ sigmasq ;

        M = diag(mass);

        % coupling coefficients between regions
        % first row
        M(1,1) = M(1,1) + coupling(2);
        M(1,2) = -coupling(2);
        %bulk of the matrix
        for k = 2 : (kmax -1)
            M(k,k) = M(k,k) + coupling(k) + coupling(k+1);
            M(k,k-1) = -coupling(k);
            M(k,k+1) = -coupling(k+1);
        end
        % last row
        M(kmax,kmax) = M(kmax,kmax) + coupling(kmax);
        M(kmax,kmax-1) = -coupling(kmax);

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
     sigma_multiplier = 1; % storing only the stdev in upper and lower limits

     % setting up the inverse covariance matrix for (a and sigmasq)
     mass = n_points .* var_x ./ sigmasq;

     % block diagonal matrix
     Covinv = zeros(2*kmax, 2*kmax);
     for k = 1 : kmax
         % upper left block
         Covinv(k,k) =  mass(k);
         % lower left block
         Covinv(kmax + k, k) = - n_points(k) / (sigmasq(k)^2) * ( a(k) * var_x(k) - yxtilde_avg(k) );
         % upper right block
         Covinv(k, kmax + k) = - n_points(k) / (sigmasq(k)^2) * ( a(k) * var_x(k) - yxtilde_avg(k) );
         % lower right block
         Covinv(kmax + k, kmax + k) = ...
             n_points(k) / (2* sigmasq(k)^2) * ...
                ( -1 + 1/(2*sigmasq(k)) *( var_y(k) - 2*a(k)*yxtilde_avg(k) + a(k)^2*var_x(k) ) );
     end
     % first row
     Covinv(1,1) = Covinv(1,1) + coupling(2);
     Covinv(1,2) = -coupling(2);
     % bulk of the matrix
     for k = 2 : (kmax-1)
         Covinv(k, k-1) = -coupling(k);
         Covinv(k, k  ) = Covinv(k, k) + coupling(k) + coupling(k+1);
         Covinv(k, k+1) = -coupling(k+1);
     end
     % last row
     Covinv(kmax, kmax-1) = -coupling(kmax);
     Covinv(kmax, kmax) = Covinv(kmax,kmax) + coupling(kmax);

     % inverting to get the covariance matrix of a and sigmasq
     Cov = inv(Covinv);


     % stdev for the fitted parameters
     std_a = zeros(kmax,1);
     std_b = zeros(kmax,1);
     std_sigmasq = zeros(kmax,1);
     for k = 1 : kmax
         std_a(k) = sqrt(Cov(k,k));
         std_b(k) = sqrt( sigmasq(k) / n_points(k) );   % the covariance for b is diagonal and independent of the cov. of a and sigmasq
         std_sigmasq(k) = sqrt( Cov(kmax + k, kmax + k) );
     end

     % confidence intervals for fitted parameters (ie. a, b, sigmasq)
     a_lower = zeros(kmax,1);
     a_upper = zeros(kmax,1);
     b_lower = zeros(kmax,1);
     b_upper = zeros(kmax,1);
     sigmasq_lower = zeros(kmax,1);
     sigmasq_upper = zeros(kmax,1);
     for k = 1 : kmax
         a_lower(k) = a(k) - sigma_multiplier * std_a(k);
         a_upper(k) = a(k) + sigma_multiplier * std_a(k);
         b_lower(k) = b(k) - sigma_multiplier * std_b(k);
         b_upper(k) = b(k) + sigma_multiplier * std_b(k);
         sigmasq_lower(k) = sigmasq(k) - sigma_multiplier * std_sigmasq(k);
         sigmasq_upper(k) = sigmasq(k) + sigma_multiplier * std_sigmasq(k);
     end
