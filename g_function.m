function [g] = g_function(E, K)
    % % E: Kvadratický modul gradientu (E = |grad u|^2)
    % % K: Koeficient citlivosti (hrana sa detekuje, ak E > K^2
    % K2 = K^2;
    % g = 1 ./ (1 + (E / K2)); % toto je vzorec z internetu( v zosite bol 1/1+K(ux)^2)
    g = 1 ./ (1 + K * E); 
end