clear; close all; clc;

out = sim("geometric_control_template.slx");


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
    'Position',         {'$p_{b,x}$', '$p_{b,y}$', '$p_{b,z}$'}, '[m]'
    'Linear_velocity',  {'$\dot{p}_{b,x}$', '$\dot{p}_{b,y}$', '$\dot{p}_{b,z}$'}, '[m/s]'
    'omega_bb',         {'$\omega_{b,x}$', '$\omega_{b,y}$', '$\omega_{b,z}$'}, '[rad/s]'
    'tau_b',            {'$\tau_x$', '$\tau_y$', '$\tau_z$'}, '[Nm]'
    'err_R',            {'$e_{R,x}$', '$e_{R,y}$', '$e_{R,z}$'}, '[rad]'
    'err_W',            {'$e_{\omega,x}$', '$e_{\omega,y}$', '$e_{\omega,z}$'}, '[rad/s]'
    'err_p',            {'$e_{p,x}$', '$e_{p,y}$', '$e_{p,z}$'}, '[m]'
    'dot_err_p',        {'$\dot{e}_{p,x}$', '$\dot{e}_{p,y}$', '$\dot{e}_{p,z}$'}, '[m/s]'
};

for i = 1:size(vector_signals,1)
    field = vector_signals{i,1};
    legend_labels = vector_signals{i,2};
    y_unit = vector_signals{i,3};

    try
        ts = get(out, field);
        if ~isempty(ts.Data) && size(ts.Data,2) >= 3
            figure('Color', 'w', 'Renderer', 'painters', 'Position', [100 100 800 700]);

            for j = 1:3
                subplot(3,1,j);
                plot(ts.Time, ts.Data(:,j), 'LineWidth', 1.5);
                ylabel(y_unit, 'Interpreter', 'latex');
                legend(legend_labels{j}, 'Interpreter', 'latex', 'Location', 'best');
                if j == 3
                    xlabel('Time [s]', 'Interpreter', 'latex');
                end
                grid on; box on;
            end

            print(gcf, '-depsc2', fullfile(outputFolder, [field '.eps']));
        else
            warning("Il segnale %s ha dati insufficienti.", field);
        end
    catch
        warning("Il campo %s non è stato trovato in ''out''.", field);
    end
end


scalar_signals = {
    'uT', '$u_T$', '[N]'
};

for i = 1:size(scalar_signals,1)
    field = scalar_signals{i,1};
    legend_label = scalar_signals{i,2};
    y_unit = scalar_signals{i,3};

    try
        ts = get(out, field);
        if ~isempty(ts.Data)
            figure('Color', 'w', 'Renderer', 'painters', 'Position', [100 100 800 300]);
            plot(ts.Time, ts.Data, 'LineWidth', 2);
            xlabel('Time [s]', 'Interpreter', 'latex');
            ylabel(y_unit, 'Interpreter', 'latex');
            legend(legend_label, 'Interpreter', 'latex', 'Location', 'best');
            grid on; box on;
            print(gcf, '-depsc2', fullfile(outputFolder, [field '.eps']));
        else
            warning("Il segnale %s è vuoto.", field);
        end
    catch
        warning("Il campo %s non è stato trovato in ''out''.", field);
    end
end
