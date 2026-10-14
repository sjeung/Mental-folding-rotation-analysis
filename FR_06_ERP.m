function FR_06_ERP(subject)
%          difficulty      angle       match
% cond 1 : 4-fold       90 deg      yes
% cond 2 : 4-fold       90 deg      no
% cond 3 : 4-fold       40 deg      yes
% cond 4 : 4-fold       40 deg      no
% cond 5 : 6-fold       90 deg      yes
% cond 6 : 6-fold       90 deg      no
% cond 7 : 6-fold       40 deg      yes
% cond 8 : 6-fold       40 deg      no
% cond 9 : 0-fold       0 deg       yes
% cond 10: 0-fold       0 deg       no

% Custom colors: [R G B] format, for condition pairs
colors = [ ...
    0.77 0.27 0.01;  % #c44601
    0.96 0.46 0.00;  % #f57600
    0.02 0.31 0.72;  % #054fb9
    0.00 0.45 0.90;  % #0073e6
    0.55 0.55 0.55;  % 
    ]; 


% parameters
chans       = {'P3', 'P4', 'Pz'};   % needed channels 
baseline    = [-200,0];             % baseline time window in ms 
tMax        = 1200;                 % max time to display

% load bemobil config
FR_bemobil_config

%% filepaths
input_filepath = [bemobil_config.study_folder '\' bemobil_config.epoched_folder  bemobil_config.filename_prefix num2str(subject)];

% load data
EEG = pop_loadset('filename', ['sub-' num2str(subject) '_' bemobil_config.epoched_filename] ,'filepath', input_filepath);

% Check exclulsion criterion No. 4 
badChans        =  find(EEG.etc.channel_rejection.bad_channel_detection); 
badChanLabels   =  {EEG.chanlocs(badChans).labels}; 
if any(contains(chans, badChanLabels))
    disp('Bad channels detected:')
    disp(badChanLabels)
    error(['One of the channels of interest rejected in participant ' num2str(subject) ': exclude this participant']); 
end

% baselining and outlier epoch rejection 
firstT  = find(EEG.times >= baseline(1), 1,'first'); 
lastT   = find(EEG.times >= baseline(2), 1,'first'); 
maxT    = find(EEG.times >= tMax, 1,'first'); 

chanInds = find(contains({EEG.chanlocs(:).labels},chans));

% Moving-window peak-to-peak artifact detection (ERPLAB, Lopez-Calderon &
% Luck, 2014), threshold 100 uV
winSamp  = round(0.200 * EEG.srate);          % 200 ms window
stepSamp = round(0.100 * EEG.srate);          % 100 ms step
starts   = unique([1:stepSamp:(EEG.pnts-winSamp+1), EEG.pnts-winSamp+1]);

rejFlag = false(1, EEG.trials);
for Ei = 1:EEG.trials
    for Ci = 1:numel(chanInds)
        x = EEG.data(chanInds(Ci), :, Ei);
        for s = starts
            seg = x(s:s+winSamp-1);
            if max(seg) - min(seg) > 100
                rejFlag(Ei) = true;
                break
            end
        end
        if rejFlag(Ei), break, end
    end
end
rejInds = find(rejFlag);

% Baseline-correct and extract ERP data / condition labels
EEG_baselined = EEG;
condInds = zeros(1, EEG.trials);
erpData  = zeros(EEG.trials, maxT);
for Ei = 1:EEG.trials
    baselineMean = mean(mean(EEG.data(chanInds, firstT:lastT, Ei), 2));
    EEG_baselined.data(chanInds,:,Ei) = EEG.data(chanInds,:,Ei) - baselineMean;
    condInds(Ei)  = str2double(EEG.epoch(Ei).eventtype{1});
    erpData(Ei,:) = mean(EEG_baselined.data(chanInds, 1:maxT, Ei), 1);
end


f = figure('Visible','off');
hold on;

nCond = 5;
lineHandles = gobjects(nCond,1);  % preallocate handles

% x-axis in ms (from EEG.times)
x = linspace(baseline(1), baseline(2)+tMax, size(erpData,2));  

for iCond = 1:nCond
    % Select the two rows for this condition
    epochInds = find(condInds == iCond*2-1 | condInds == iCond*2);
    data = erpData(setdiff(epochInds,rejInds), :);

    % Mean and 95% CI
    m  = mean(data, 1);
    sd = std(data, 0, 1);
    n  = size(data, 1);
    ci = 1.96 * (sd ./ sqrt(n));
    
    % Shaded CI
    fill([x fliplr(x)], [m-ci fliplr(m+ci)], ...
         colors(iCond,:), 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    
    % Mean line
    lineHandles(iCond) = plot(x, m, 'Color', colors(iCond,:), 'LineWidth', 2);
end

% Vertical line at stimulus onset (0 ms)
yl = ylim;  % get current y-axis limits
plot([0 0], yl, 'k--', 'LineWidth', 1.5);  % dashed black line
ylim(yl);  % keep limits fixed

% Legend only for lines
legend(lineHandles, {'4-90','4-40','6-90','6-40','0'});
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
title('Single subject ERP with 95% CI');
grid on;
box on;

saveas(f, fullfile(['P:\Sein_Jeung\Project_Fold_Rotation\Figures\subject_ERPs\sub-' num2str(subject) '_ERPs.png']))
save(fullfile(['P:\Sein_Jeung\Project_Fold_Rotation\Data\7_ERPs\sub-' num2str(subject) '_ERPs.mat']), 'erpData', 'condInds', 'rejInds');
end

