function [solution] = LD1DImplicit(u0, tau, t_steps, h)
    % u0: Initial data (1D array, initial condition)
    % tau: Time step size
    % t_steps: Number of time steps
    % h: Length of each spatial segment (space discretization)
    % solution: Solution at every time step (each row represents a time step)

    % Number of spatial points
    n_points = length(u0);
           
    % implicit scheme is unconditionally stable
    th = tau / (h^2);
    
    % Initialize the solution matrix to store the solution at every time step
    solution = zeros(t_steps, n_points);
    
    % Set the initial condition
    solution(1, :) = u0;
    
    % Create the matrix for the implicit scheme (tridiagonal system)
    main_diag = (1 + 2*th) * ones(n_points, 1);   % Main diagonal
    off_diag = -th * ones(n_points, 1);         % Off-diagonals
    
    % Construct the tridiagonal matrix A (implicit system matrix)
    A = spdiags([off_diag, main_diag, off_diag], [-1, 0, 1], n_points, n_points);
    
    % Apply Dirichlet boundary conditions
    % A(1, :) = 0;           % Zero out the first row (left boundary)
    % A(1, 1) = 1;           % Dirichlet condition at left boundary
    % A(end, :) = 0;         % Zero out the last row (right boundary)
    % A(end, end) = 1;       % Dirichlet condition at right boundary

    %  Apply Neumann boundary conditions
    A(1, 2) = -2 * th;  % Ľavý okraj 
    A(n_points, n_points - 1) = -2 * th; % Pravý okraj
    
    %Sparse matrix
%     A = spalloc(n_points,n_points,(n_points-2)*3+2);
%    
%     A(1,1) = 1;
%     A(end,end) = 1;    
%     
%     for i = 2:n_points-1
%         A(i,i) = 1+2*th;        
%         A(i,i-1) = -th;       
%         A(i,i+1) = -th;
%     end
   
    
    % Time stepping loop
    for t = 2:t_steps

        b = solution(t-1, :)'; % Pravá strana
        u_next = A \ b;   % Riešenie: A * u_next = b
        % Store the result for the current time step
        solution(t, :) = u_next';
    end
end