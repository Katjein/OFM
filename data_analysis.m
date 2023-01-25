%% Data Analysis
clc
clear
close all

cd("barefoot\"); 
load("normalized_data_barefoot.mat");

cd("../shoe\"); 
load("normalized_data_shoe.mat");

%%
list_parameters = {'RTIBA'}; % list parameters that should be displayed % 'RFFHFA', 'RHFTBA','RFFTBA'
for current_parameter = 1 : length(list_parameters)
    % saggital
    figure(1) % Dorsalflexion
    subplot(ceil(length(list_parameters)), 1, current_parameter)
    plot(barefoot.mean.(cell2mat(list_parameters(current_parameter)))(:, 1) )
    hold on
    plot(shoe.mean.(cell2mat(list_parameters(current_parameter)))(:, 1) )
    title(list_parameters(current_parameter))
    legend('barefoot', 'shoe')

    % transversal & Rotation
    figure(2) 
    subplot(ceil(length(list_parameters)), 1, current_parameter)
    plot(barefoot.mean.(cell2mat(list_parameters(current_parameter)))(:, 2) )
    hold on
    plot(shoe.mean.(cell2mat(list_parameters(current_parameter)))(:, 2) )
    title(list_parameters(current_parameter))
    legend('barefoot', 'shoe')

    % frontal & Pronation/Supination
    figure(3) 
    subplot(ceil(length(list_parameters)), 1, current_parameter)
    plot(barefoot.mean.(cell2mat(list_parameters(current_parameter)))(:, 3) )
    hold on
    plot(shoe.mean.(cell2mat(list_parameters(current_parameter)))(:, 3) )
    title(list_parameters(current_parameter))
    legend('barefoot', 'shoe')
end


%% CONFIDENCE BANDS
for row = 1 : length(barefoot.interp.RTIBA.x(:, 1))
    barefoot.std.RTIBA(row, :) = std(barefoot.interp.RTIBA.x(row, :));
    barefoot.CI(row, 1) = barefoot.mean.RTIBA(row, 1) - (1.96 *barefoot.std.RTIBA(row)); % lower CI
    barefoot.CI(row, 2) = barefoot.mean.RTIBA(row, 1) + (1.96 *barefoot.std.RTIBA(row)); % upper CI
end

x = 1 : 1 : 101;
figure(1)
patch([x fliplr(x)], [barefoot.CI(:, 1)' fliplr(barefoot.CI(:, 2)')], [0, 0.4470, 0.7410], FaceAlpha=0.3);


% -> ganze Kurve vergleichen vs. Kennmale 
% -> interpolation ganz oder über peaks/valleys


%% Limitations
% - case study
% - 12x4 Schritte statt 50 am Stück -> unterschiedlichere Gangzyklen

