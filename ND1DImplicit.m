function [solution] = ND1DImplicit(u0, tau, t_steps, h, K)
    % Nelineárna Difúzia 1D s Nulovým Neumannom (Semi-Implicitná Schéma)
    
    n_points = length(u0);
    solution = zeros(t_steps, n_points);
    solution(1, :) = u0;
    
    u_current = u0;
    if iscolumn(u_current); u_current = u_current'; end 
    
    th = tau / h; % Pomocný parameter tau/h
    
    for t = 2:t_steps
        
        % --- Krok 1: Získanie vyhladeného signálu u_sigma ---
        u_sigma_solution = LD1DImplicit(u_current, tau, 2, h); 
        u_sigma = u_sigma_solution(end, :)'; % Vyhladený stĺpcový vektor
        
        % --- Krok 2: Výpočet gradientov a koeficientov g (na rozhraniach) ---
        
        % Vektor tokov/gradientov (dĺžka n_points - 1)
        grad_u_sigma = diff(u_sigma) / h; 
        E = grad_u_sigma.^2; 
        g_interfaces = g_function(E, K); % Vektor g(i+1/2)
        if isrow(g_interfaces); g_interfaces = g_interfaces'; end
        
        % --- Krok 3: Konštrukcia Tridiagonálnej Matice A pomocou cyklu ---
        
        % Inicializácia riedkej matice (lepšie pre pamäť a rýchlosť)
        A = spalloc(n_points, n_points, (n_points - 2) * 3 + 4); 
        
        % --- Nastavenie VNÚTORNÝCH BODOV (i = 2 až n_points - 1) ---
        
        for i = 2:n_points - 1
            % g_L (tok i-1 -> i) = g_interfaces(i-1)
            gL = g_interfaces(i - 1); 
            
            % g_R (tok i -> i+1) = g_interfaces(i)
            gR = g_interfaces(i);     
            
            % Hlavná diagonála A(i, i): 1 + tau/h * (gL + gR)
            A(i, i) = 1 + th * (gL + gR); 
            
            % Spodná diagonála A(i, i-1): -tau/h * gL
            A(i, i - 1) = -th * gL;
            
            % Horná diagonála A(i, i+1): -tau/h * gR
            A(i, i + 1) = -th * gR;
        end
        
        % --- Krok 4: NULOVÉ NEUMANNOVÉ OKRAJOVÉ PODMIENKY ---
        
        % Koeficient g na ĽAVOM okraji (i=1) a PRAVOM okraji (i=N)
        g_left = g_interfaces(1);       % Tok medzi 1 a 2
        g_right = g_interfaces(end);    % Tok medzi N-1 a N

        % Ľavý okraj (i = 1):
        % Používame fiktívny bod u_0 = u_1 (g_L = g_R)
        A(1, 1) = 1 + th * 2 * g_left;
        A(1, 2) = -th * 2 * g_left;
        
        % Pravý okraj (i = n_points):
        % Používame fiktívny bod u_{N+1} = u_N (g_R = g_L)
        A(n_points, n_points) = 1 + th * 2 * g_right;
        A(n_points, n_points - 1) = -th * 2 * g_right;
        
        
        % --- Krok 5: Riešenie sústavy A * u_next = u_current ---
        
        b = u_current'; % Pravá strana (aktuálny stav, stĺpcový vektor)
        u_next = A \ b;
        
        % Store the result and update u_current
        u_current = u_next'; % Pre ďalšiu iteráciu je riadkový
        solution(t, :) = u_current;
    end
end