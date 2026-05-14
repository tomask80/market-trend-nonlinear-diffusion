clearvars
data = readtable('data/pep_6m_price.csv'); 

close_prices = data.Close; 

N = 127; 
if length(close_prices) > N
    u0_raw = close_prices(end-N+1:end); 
else
    u0_raw = close_prices;
    N = length(u0_raw);
end
u0_raw_cell = u0_raw;

u0_cleaned_cell = cellfun(@(x) strrep(x, '$', ''), u0_raw_cell, 'UniformOutput', false);
u0_numeric = str2double(u0_cleaned_cell); 


disp(class(u0_numeric)); 
disp(u0_numeric(1:5)); 


u0_raw = u0_numeric; 
u_min = min(u0_raw);
u_max = max(u0_raw);


if u_max - u_min == 0
    u0 = u0_raw; 
else
    u0 = (u0_raw - u_min) / (u_max - u_min);
end

if isrow(u0); u0 = u0'; end

figure;


n_points=length(u0_numeric);
x_indices = 1:n_points;


subplot(2, 1, 1);
plot(x_indices, u0_raw, 'b-', 'LineWidth', 1.5);
title('Pôvodné Ceny Akcie PEP (Ne-normalizované)');
xlabel('Čas (Dátové body)');
ylabel('Cena ($)');
grid on;


subplot(2, 1, 2);
plot(x_indices, u0, 'r-', 'LineWidth', 1.5);
title('Normalizovaná Počiatočná Podmienka (u0)');
xlabel('Čas (Dátové body)');
ylabel('Normalizovaná Hodnota (0-1)');
ylim([-0.1 1.1]); 
grid on;


sgtitle('Príprava Dát Akcie PEP pre Difúzny Filter');

tau = 0.5;         
t_steps = 3;   
h = 1;           
K = 10;      


solution_linear = LD1DImplicit(u0, tau, t_steps, h);

solution_nelinear = ND1DImplicit(u0, tau, t_steps, h, K);

SMA_Window = 10; 
sma_solution = calculateSMA(u0, SMA_Window);

figure;
hold on;

plot(x_indices, u0, 'LineWidth', 1.5, 'DisplayName', 'PP'); 

%plot(x_indices, solution_linear(end, :), 'LineWidth',1 , 'DisplayName', 'LD (Vyhladené)'); 

plot(x_indices, solution_nelinear(end, :), 'LineWidth', 1, 'DisplayName', [' ND (K=', num2str(K), ')']); 

plot(x_indices, sma_solution, 'LineWidth', 1, 'DisplayName', ['SMA, W=', num2str(SMA_Window), ')']);
xlabel('Dátový bod (Čas)');
ylabel('Normalizovaná Hodnota');
title(['Porovnanie Lineárnej a Nelineárnej Difúzie a SMA na Cenách PEP (T=', num2str(t_steps), ')']);

legend('Location', 'best');
grid on;
hold off;

xlim([0 140])
ylim([0.00 1.00])
title("Comparison of nonlinear diffusion to SMA")
xlabel("time")
ylabel("Normalized price")

