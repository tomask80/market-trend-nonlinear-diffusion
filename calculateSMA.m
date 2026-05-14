function sma_result = calculateSMA(data, window)
    % data: stlpcovy vektor normalizovanych cien (u0)
    % window: velkost okna (napr. 10, 20)
    
    N = length(data);
    sma_result = zeros(N, 1);
    
    % Vypocet priemeru pre kazde okno
    for i = 1:N
        % Zaciatok okna: max(1, i - window + 1)
        start_index = max(1, i - window + 1);
        
        % Vypocet priemeru zo vsetkych dostupnych bodov v okne
        sma_result(i) = mean(data(start_index:i));
    end
end