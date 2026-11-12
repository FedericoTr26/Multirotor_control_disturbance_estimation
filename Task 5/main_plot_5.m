clear; close all; clc;


out = sim("tilting_control_voliro_template.slx");

set(0, 'DefaultAxesFontName', 'Times New Roman');
set(0, 'DefaultTextInterpreter', 'latex');
set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
set(0, 'DefaultLegendInterpreter', 'latex');
set(0, 'DefaultAxesFontSize', 16);
set(0, 'DefaultLineLineWidth', 1.5);
set(0, 'DefaultFigureColor', 'w');

% === Crea cartella output se non esiste ===
outputFolder = fullfile(pwd, 'figures');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end


vector_signals = {
    'err_p',        {'$e_{p,x}$', '$e_{p,y}$', '$e_{p,z}$'},             '[m]'
    'dot_err_p',    {'$\dot{e}_{p,x}$', '$\dot{e}_{p,y}$', '$\dot{e}_{p,z}$'}, '[m/s]'
    'eR',           {'$e_{R,x}$', '$e_{R,y}$', '$e_{R,z}$'},             '[rad]'
    'ew',           {'$e_{\omega,x}$', '$e_{\omega,y}$', '$e_{\omega,z}$'}, '[rad/s]'
    'uw', {'$u_{\omega_1}$', '$u_{\omega_2}$', '$u_{\omega_3}$', '$u_{\omega_4}$'}, '[rad/s]'
    'alfa',         {'$\alpha_1$', '$\alpha_2$', '$\alpha_3$', '$\alpha_4$'}, '[rad]'
};

% === Titoli per le figure ===
quantity_titles = containers.Map( ...
    {'err_p', 'dot_err_p', 'eR', 'ew', 'uw', 'alfa'}, ...
    {'Position Error', 'Velocity Error', 'Orientation Error', ...
     'Angular Velocity Error', 'Rotor Speeds', 'Rotor Orientations'} ...
);

% === Colori visibili e ad alto contrasto (max 4 componenti) ===
plot_colors = {
    [0 0 0],        ... Nero
    [1 0 0],        ... Rosso
    [0 0 1],        ... Blu
    [1 0 1]         ... Magenta
};

% === Loop principale per plottare ===
for i = 1:size(vector_signals,1)
    field = vector_signals{i,1};
    labels = vector_signals{i,2};
    unit_y = vector_signals{i,3};
    n_components = length(labels);

    try
        ts = get(out, field);

        if isa(ts, 'timeseries')
            t = ts.Time;
            data = ts.Data;

            % Plot
            figure('Color', 'w', 'Renderer', 'painters', ...
                'Position', [100 100 800 400]);

            hold on;
            for j = 1:n_components
                plot(t, data(:,j), 'Color', plot_colors{j}, 'LineWidth', 1.5);
            end
            hold off;

            grid on; box on;
            xlabel('Time [s]', 'Interpreter', 'latex');
            ylabel(unit_y, 'Interpreter', 'latex');
            legend(labels, 'Interpreter','latex', 'Location', 'best');
            title(quantity_titles(field), 'Interpreter','latex');

            % Salva in EPS con suffisso "_5"
            filename = [field '_5.eps'];
            print(gcf, '-depsc2', fullfile(outputFolder, filename));
        else
            warning("Il campo %s non è una timeseries.", field);
        end

    catch
        warning("Il segnale %s non è stato trovato in 'out'.", field);
    end
end
