%% Data Analysis
clc
clear
close all

base_path = pwd;
cd("barefoot\");
load("normalized_data_barefoot.mat");
cd("../shoe\");
load("normalized_data_shoe.mat");
cd(base_path)

%%
list_parameters = {'RFFTBA','RHFTBA','RFFHFA','RHXFFA'}; % list parameters that should be displayed % 'RFFHFA', 'RHFTBA','RFFTBA'
x = 1:1:length(barefoot.mean.LANA);

for current_parameter = 1 : length(list_parameters)

    % CONFIDENCE BANDS
    for row = 1 : length(barefoot.interp.LANA.x(:, 1))
        % BAREFOOT
        barefoot.std.(cell2mat(list_parameters(current_parameter)))(row, 1) = ...
            std(barefoot.interp.(cell2mat(list_parameters(current_parameter))).x(row, :));
        barefoot.std.(cell2mat(list_parameters(current_parameter)))(row, 2) = ...
            std(barefoot.interp.(cell2mat(list_parameters(current_parameter))).y(row, :));
        barefoot.std.(cell2mat(list_parameters(current_parameter)))(row, 3) = ...
            std(barefoot.interp.(cell2mat(list_parameters(current_parameter))).z(row, :));
        % lower CI
        barefoot.CI.lower.(cell2mat(list_parameters(current_parameter)))(row, 1) = ...
            barefoot.mean.(cell2mat(list_parameters(current_parameter)))(row, 1) - (1.96 *barefoot.std.(cell2mat(list_parameters(current_parameter)))(row, 1));
        barefoot.CI.lower.(cell2mat(list_parameters(current_parameter)))(row, 2) = ...
            barefoot.mean.(cell2mat(list_parameters(current_parameter)))(row, 2) - (1.96 *barefoot.std.(cell2mat(list_parameters(current_parameter)))(row, 2));
        barefoot.CI.lower.(cell2mat(list_parameters(current_parameter)))(row, 3) = ...
            barefoot.mean.(cell2mat(list_parameters(current_parameter)))(row, 3) - (1.96 *barefoot.std.(cell2mat(list_parameters(current_parameter)))(row, 3));
        % upper CI
        barefoot.CI.upper.(cell2mat(list_parameters(current_parameter)))(row, 1) = ...
            barefoot.mean.(cell2mat(list_parameters(current_parameter)))(row, 1) + (1.96 *barefoot.std.(cell2mat(list_parameters(current_parameter)))(row, 1));
        barefoot.CI.upper.(cell2mat(list_parameters(current_parameter)))(row, 2) = ...
            barefoot.mean.(cell2mat(list_parameters(current_parameter)))(row, 2) + (1.96 *barefoot.std.(cell2mat(list_parameters(current_parameter)))(row, 2));
        barefoot.CI.upper.(cell2mat(list_parameters(current_parameter)))(row, 3) = ...
            barefoot.mean.(cell2mat(list_parameters(current_parameter)))(row, 3) + (1.96 *barefoot.std.(cell2mat(list_parameters(current_parameter)))(row, 3));

        % SHOE
        shoe.std.(cell2mat(list_parameters(current_parameter)))(row, 1) = ...
            std(shoe.interp.(cell2mat(list_parameters(current_parameter))).x(row, :));
        shoe.std.(cell2mat(list_parameters(current_parameter)))(row, 2) = ...
            std(shoe.interp.(cell2mat(list_parameters(current_parameter))).y(row, :));
        shoe.std.(cell2mat(list_parameters(current_parameter)))(row, 3) = ...
            std(shoe.interp.(cell2mat(list_parameters(current_parameter))).z(row, :));
        % lower CI
        shoe.CI.lower.(cell2mat(list_parameters(current_parameter)))(row, 1) = ... % X
            shoe.mean.(cell2mat(list_parameters(current_parameter)))(row, 1) - (1.96 *shoe.std.(cell2mat(list_parameters(current_parameter)))(row, 1));
        shoe.CI.lower.(cell2mat(list_parameters(current_parameter)))(row, 2) = ... % Y
            shoe.mean.(cell2mat(list_parameters(current_parameter)))(row, 2) - (1.96 *shoe.std.(cell2mat(list_parameters(current_parameter)))(row, 2));
        shoe.CI.lower.(cell2mat(list_parameters(current_parameter)))(row, 3) = ... % Z
            shoe.mean.(cell2mat(list_parameters(current_parameter)))(row, 3) - (1.96 *shoe.std.(cell2mat(list_parameters(current_parameter)))(row, 3));
        % upper CI
        shoe.CI.upper.(cell2mat(list_parameters(current_parameter)))(row, 1) = ... % X
            shoe.mean.(cell2mat(list_parameters(current_parameter)))(row, 1) + (1.96 *shoe.std.(cell2mat(list_parameters(current_parameter)))(row, 1));
        shoe.CI.upper.(cell2mat(list_parameters(current_parameter)))(row, 2) = ... % Y
            shoe.mean.(cell2mat(list_parameters(current_parameter)))(row, 2) + (1.96 *shoe.std.(cell2mat(list_parameters(current_parameter)))(row, 2));
        shoe.CI.upper.(cell2mat(list_parameters(current_parameter)))(row, 3) = ... % Z
            shoe.mean.(cell2mat(list_parameters(current_parameter)))(row, 3) + (1.96 *shoe.std.(cell2mat(list_parameters(current_parameter)))(row, 3));

        %% Descriptive Stats
        for col = 1 : length(barefoot.interp.LANA.x(1, :))

            barefoot.ROM.(cell2mat(list_parameters(current_parameter)))(col, :) = [...
                max(barefoot.interp.(cell2mat(list_parameters(current_parameter))).x(:, col)) - min(barefoot.interp.(cell2mat(list_parameters(current_parameter))).x(:, col)), ...
                max(barefoot.interp.(cell2mat(list_parameters(current_parameter))).y(:, col)) - min(barefoot.interp.(cell2mat(list_parameters(current_parameter))).y(:, col)), ...
                max(barefoot.interp.(cell2mat(list_parameters(current_parameter))).z(:, col)) - min(barefoot.interp.(cell2mat(list_parameters(current_parameter))).z(:, col))];
            shoe.ROM.(cell2mat(list_parameters(current_parameter)))(col, :) = [...
                max(shoe.interp.(cell2mat(list_parameters(current_parameter))).x(:, col)) - min(shoe.interp.(cell2mat(list_parameters(current_parameter))).x(:, col)), ...
                max(shoe.interp.(cell2mat(list_parameters(current_parameter))).y(:, col)) - min(shoe.interp.(cell2mat(list_parameters(current_parameter))).y(:, col)), ...
                max(shoe.interp.(cell2mat(list_parameters(current_parameter))).z(:, col)) - min(shoe.interp.(cell2mat(list_parameters(current_parameter))).z(:, col))];

            barefoot.meanROM.(cell2mat(list_parameters(current_parameter))) = [...
                mean(barefoot.ROM.(cell2mat(list_parameters(current_parameter)))(:, 1)), ...
                mean(barefoot.ROM.(cell2mat(list_parameters(current_parameter)))(:, 2)), ...
                mean(barefoot.ROM.(cell2mat(list_parameters(current_parameter)))(:, 3))];
            shoe.meanROM.(cell2mat(list_parameters(current_parameter))) = [...
                mean(shoe.ROM.(cell2mat(list_parameters(current_parameter)))(:, 1)), ...
                mean(shoe.ROM.(cell2mat(list_parameters(current_parameter)))(:, 2)), ...
                mean(shoe.ROM.(cell2mat(list_parameters(current_parameter)))(:, 3))];

            barefoot.stdROM.(cell2mat(list_parameters(current_parameter))) = [...
                std(barefoot.ROM.(cell2mat(list_parameters(current_parameter)))(:, 1)), ...
                std(barefoot.ROM.(cell2mat(list_parameters(current_parameter)))(:, 2)), ...
                std(barefoot.ROM.(cell2mat(list_parameters(current_parameter)))(:, 3))];
            shoe.stdROM.(cell2mat(list_parameters(current_parameter))) = [...
                std(shoe.ROM.(cell2mat(list_parameters(current_parameter)))(:, 1)), ...
                std(shoe.ROM.(cell2mat(list_parameters(current_parameter)))(:, 2)), ...
                std(shoe.ROM.(cell2mat(list_parameters(current_parameter)))(:, 3))];

        end


        mean_diff(current_parameter,:) = barefoot.meanROM.(cell2mat(list_parameters(current_parameter))) - shoe.meanROM.(cell2mat(list_parameters(current_parameter)));
        for std_counter = 1:length(shoe.stdROM.(cell2mat(list_parameters(current_parameter)))(:,:))
            std_1 = barefoot.stdROM.(cell2mat(list_parameters(current_parameter)))(std_counter);
            std_2 = shoe.stdROM.(cell2mat(list_parameters(current_parameter)))(std_counter);
            mean_std(current_parameter,std_counter) = sqrt(std_1.^2 / col + std_2.^2 / col);
        end
% σd = sqrt( σ1^^2 / n1 + σ2^^2 / n2 )


    end
    %% RELIABILITY
    % ICC
    % SEM

    % Bland Altman
    % for all data at a specific point in time
    bad = blandAltmanDiagram(barefoot.interp.RFFHFA.y(60, :), shoe.interp.RFFHFA.y(60, :));

    %% PLOTS
    % saggital = Dorsalflexion
    figure(1)
    subplot(ceil(length(list_parameters)), 1, current_parameter)
    hold on
    % barefoot
    patch([x fliplr(x)], ...
        [barefoot.CI.lower.(cell2mat(list_parameters(current_parameter)))(:, 1)', ... % lower limit
        fliplr(barefoot.CI.upper.(cell2mat(list_parameters(current_parameter)))(:, 1)')], ... % upper limit
        [0, 0.4470, 0.7410], ... % color
        FaceAlpha=0.3, ...     % intensity
        EdgeColor='none');
    plot(barefoot.mean.(cell2mat(list_parameters(current_parameter)))(:, 1) )
    %shoe
    patch([x fliplr(x)], ...
        [shoe.CI.lower.(cell2mat(list_parameters(current_parameter)))(:, 1)', ... % lower limit
        fliplr(shoe.CI.upper.(cell2mat(list_parameters(current_parameter)))(:, 1)')], ... % upper limit
        [0.8500 0.3250 0.0980], ... % color
        FaceAlpha=0.3, ...     % intensity
        EdgeColor='none');
    plot(shoe.mean.(cell2mat(list_parameters(current_parameter)))(:, 1) )
    title(list_parameters(current_parameter))
    subtitle('Saggital Plane')
    legend('CI barefoot', 'barefoot mean', 'CI shoe', 'shoe mean')
    xlabel('Gait Cycle (%)')
    ylabel('Dorsiflexion (deg)')

    % transversal = Rotation
    figure(2)
    subplot(ceil(length(list_parameters)), 1, current_parameter)
    hold on
    patch([x fliplr(x)], ...
        [barefoot.CI.lower.(cell2mat(list_parameters(current_parameter)))(:, 2)', ... % lower limit
        fliplr(barefoot.CI.upper.(cell2mat(list_parameters(current_parameter)))(:, 2)')], ... % upper limit
        [0, 0.4470, 0.7410], ... % color
        FaceAlpha=0.3, ...     % intensity
        EdgeColor='none');
    plot(barefoot.mean.(cell2mat(list_parameters(current_parameter)))(:, 2) )
    % shoe
    patch([x fliplr(x)], ...
        [shoe.CI.lower.(cell2mat(list_parameters(current_parameter)))(:, 2)', ... % lower limit
        fliplr(shoe.CI.upper.(cell2mat(list_parameters(current_parameter)))(:, 2)')], ... % upper limit
        [0.8500 0.3250 0.0980], ... % color
        FaceAlpha=0.3, ...     % intensity
        EdgeColor='none');
    plot(shoe.mean.(cell2mat(list_parameters(current_parameter)))(:, 2) )
    title(list_parameters(current_parameter))
    subtitle('Transversal Plane')
    legend('CI barefoot', 'barefoot mean', 'CI shoe', 'shoe mean')
    xlabel('Gait Cycle (%)')
    ylabel('External Rotation (deg)')

    % frontal = Pronation/Supination
    figure(3)
    subplot(ceil(length(list_parameters)), 1, current_parameter)
    hold on
    % barefoot
    patch([x fliplr(x)], ...
        [barefoot.CI.lower.(cell2mat(list_parameters(current_parameter)))(:, 3)', ... % lower limit
        fliplr(barefoot.CI.upper.(cell2mat(list_parameters(current_parameter)))(:, 3)')], ... % upper limit
        [0, 0.4470, 0.7410], ... % color
        FaceAlpha=0.3, ...     % intensity
        EdgeColor='none');
    plot(barefoot.mean.(cell2mat(list_parameters(current_parameter)))(:, 3) )
    % shoe
    patch([x fliplr(x)], ...
        [shoe.CI.lower.(cell2mat(list_parameters(current_parameter)))(:, 3)', ... % lower limit
        fliplr(shoe.CI.upper.(cell2mat(list_parameters(current_parameter)))(:, 3)')], ... % upper limit
        [0.8500 0.3250 0.0980], ... % color
        FaceAlpha=0.3, ...     % intensity
        EdgeColor='none');
    plot(shoe.mean.(cell2mat(list_parameters(current_parameter)))(:, 3) )
    title(list_parameters(current_parameter))
    subtitle('Frontal Plane')
    legend('CI barefoot', 'barefoot mean', 'CI shoe', 'shoe mean')
    xlabel('Gait Cycle (%)')
    ylabel('Pronation/Supination (deg)')

end

% 5 - BLAND ALTMAN PLOT
figure(5)
scatter( bad.median, bad.diff)
hold on
yline(bad.LoA(1), Color=[1 0 0], LineStyle="--")
yline(bad.LoA(2), Color=[1 0 0], LineStyle="-.")
yline(bad.meanDiff, Color=[0 0 0], LineStyle="--")
legend( "datapoints", "Lower Limit of Agreement", "Upper Limit of Agreement", "Mean")
title("Bland-Altmann-Diagramm")
xlabel( "median" )
ylabel( "discrepancy" )





%% Limitations
% - case study
% - 12x4 Schritte statt 50 am Stück -> unterschiedlichere Gangzyklen



function blandAltman = blandAltmanDiagram(data1, data2)
% Bland-Altman-Diagramm
% 95% Confidence Interval

diff = data1 - data2;     %diff
median_BAD = zeros([length(diff), 1]); %median
for C = 1 : length(data1)
    median_BAD(C, 1) = median( [data1(C), data2(C)]);
end

SD = std(diff);     %std

KI95 = SD * 1.96;   % 95% Confidence Intervall

mean_BAD = mean(diff);
LoA(2) = mean_BAD + KI95;
LoA(1) = mean_BAD - KI95;

blandAltman = struct('diff', diff, 'median', median_BAD, 'meanDiff', mean_BAD, 'LoA', LoA);
end