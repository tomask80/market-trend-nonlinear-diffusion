function [solution] = ND1DImplicit(u0, tau, t_steps, h, K)
    % Nelineárna Difúzia 1D s Nulovým Neumannom (Semi-Implicitná Schéma)
    
    n_points = length(u0);
    solution = zeros(t_steps, n_points);
    solution(1, :) = u0;
    
    u_current = u0;
    if iscolumn(u_current); u_current = u_current'; end 
    
    th = tau / h; % Pomocný parameter tau/h
    
    for t = 2:t_steps
        
        u_sigma_solution = LD1DImplicit(u_current, tau, 2, h); 
        u_sigma = u_sigma_solution(end, :)';
        grad_u_sigma = diff(u_sigma) / h; 
        E = grad_u_sigma.^2; 
        g_interfaces = g_function(E, K);
        if isrow(g_interfaces); g_interfaces = g_interfaces'; end

        A = spalloc(n_points, n_points, (n_points - 2) * 3 + 4);
     
        for i = 2:n_points - 1
            gL = g_interfaces(i - 1); 
            
            gR = g_interfaces(i);     
            
            A(i, i) = 1 + th * (gL + gR); 
   
            A(i, i - 1) = -th * gL;
            
            A(i, i + 1) = -th * gR;
        end
        
        g_left = g_interfaces(1);      
        g_right = g_interfaces(end);   

        A(1, 1) = 1 + th * 2 * g_left;
        A(1, 2) = -th * 2 * g_left;
        
        A(n_points, n_points) = 1 + th * 2 * g_right;
        A(n_points, n_points - 1) = -th * 2 * g_right;
        
        b = u_current'; 
        u_next = A \ b;

        u_current = u_next';
        solution(t, :) = u_current;
    end
end