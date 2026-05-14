function [solution] = LD1DImplicit(u0, tau, t_steps, h)
    n_points = length(u0);
    th = tau / (h^2);

    solution = zeros(t_steps, n_points);
    solution(1, :) = u0;
    
    main_diag = (1 + 2*th) * ones(n_points, 1);   
    off_diag = -th * ones(n_points, 1);         
    
    A = spdiags([off_diag, main_diag, off_diag], [-1, 0, 1], n_points, n_points);
    
    % Apply Dirichlet boundary conditions
    % A(1, :) = 0;           % Zero out the first row (left boundary)
    % A(1, 1) = 1;           % Dirichlet condition at left boundary
    % A(end, :) = 0;         % Zero out the last row (right boundary)
    % A(end, end) = 1;       % Dirichlet condition at right boundary

    %  Apply Neumann boundary conditions
    A(1, 2) = -2 * th; 
    A(n_points, n_points - 1) = -2 * th; 
    
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
   
    for t = 2:t_steps

        b = solution(t-1, :)'; 
        u_next = A \ b;   
        solution(t, :) = u_next';
    end
end