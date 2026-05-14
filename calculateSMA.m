function sma_result = calculateSMA(data, window)

    N = length(data);
    sma_result = zeros(N, 1);
    
    for i = 1:N
        start_index = max(1, i - window + 1);
        
        sma_result(i) = mean(data(start_index:i));
    end
end