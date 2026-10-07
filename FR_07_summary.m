
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

% time window of interest
time        = (-0.2:1/250:1.2);
tWindow     = [0.4,0.8]; % 400 to 800 ms from onset
tIndices    = find(time >= tWindow(1) & time <= tWindow(2));

% figure path
fPath = 'P:\Sein_Jeung\Project_Fold_Rotation\Figures\aggregated.png';

% condition mapping
condMap = [
    1  4  90
    2  4  90
    3  4  40
    4  4  40
    5  6  90
    6  6  90
    7  6  40
    8  6  40
    9  0   0
    10 0   0
    ];

condpairs   = [4, 90; 4, 40; 6, 90; 6, 40; 0, 0]; 


condLabels = {
    '4-fold, 90°'
    '4-fold, 40°'
    '6-fold, 90°'
    '6-fold, 40°'
    'Baseline'
};

% Colors for angle
col40   = [0.941 0.690 0.439];   % #f0b070
col90   = [0.247 0.498 0.769];   % #3f7fc4
colBase = [0.72 0.72 0.72];      % unchanged

colors = {
    col90
    col40
    col90
    col40
    colBase
};

lineStyles = {
    '-'
    '-'
    '--'
    '--'
    '-'
};

% aggregate
%--------------------------------------------------------------------------
grandCell       = {}; 
T = table( ...
    strings(0,1), ...   % Subject
    zeros(0,1), ...     % Trial
    zeros(0,1), ...     % FoldingDifficulty
    zeros(0,1), ...     % FoldingAngle
    zeros(0,1), ...     % ParietalNegativity
    zeros(0,1), ...     % Latency
    'VariableNames', { ...
        'Subject', ...
        'Trial', ...
        'FoldingDifficulty', ...
        'FoldingAngle', ...
        'ParietalNegativity',...
        'latency'});

for iPair = 1:5

    grandMat = [];

    for Pi = participants


        pmat = load(['P:\Sein_Jeung\Project_Fold_Rotation\Data\7_ERPs\sub-' ...
            num2str(Pi) '_ERPs.mat']);

        beh = load(['P:\Sein_Jeung\Project_Fold_Rotation\Data\6_epoched\sub-' ...
            num2str(Pi) '\sub-'  num2str(Pi)  '_RT.mat']);
    
         assert(height(beh.BEH) == numel(pmat.condInds), ...
            'sub-%d: beh.BEH has %d rows but pmat.condInds has %d — alignment cannot be assumed.', ...
            Pi, height(beh.BEH), numel(pmat.condInds));

        fold = condpairs(iPair,1); angle = condpairs(iPair,2); 

        selectedConds = condMap(condMap(:,2) == fold & condMap(:,3) == angle, 1);
        trialInds = ismember(pmat.condInds, selectedConds);
        participantERP = mean(pmat.erpData(trialInds, :), 1);

        
        % compute trial-specific negativity
        pNeg        = mean(pmat.erpData(trialInds, tIndices),2); 

        latency   = beh.BEH.RT(trialInds);          % reaction time as latency
        trialNums = beh.BEH.Count(trialInds);        % real trial number, from the Count column

        grandMat(end+1, :) = participantERP;

        nTrials = sum(trialInds);
        newRows = table( ...
            repmat(string(Pi), nTrials, 1), ...
            trialNums(:), ...
            repmat(fold, nTrials, 1), ...
            repmat(angle, nTrials, 1), ...
            pNeg(:), ...
            latency(:), ...
            'VariableNames', T.Properties.VariableNames);

        T = [T; newRows];

        % Add participant ERP as one row
        grandMat(end+1, :) = participantERP;
    end

    grandCell{iPair} = grandMat; 

end


% visualize
%--------------------------------------------------------------------------

figure;
hold on;

h = gobjects(5,1);

for iPair = 1:5
    data = grandCell{iPair};
    meanERP = mean(data, 1, 'omitnan');

    n = sum(~isnan(data), 1);
    semERP = std(data, 0, 1, 'omitnan') ./ sqrt(n);
    CI = 1.96 .* semERP;

    upper = meanERP + CI;
    lower = meanERP - CI;

    % CI shading
    fill([time fliplr(time)], ...
         [upper fliplr(lower)], ...
         colors{iPair}, ...
         'FaceAlpha', 0.15, ...
         'EdgeColor', 'none', ...
         'HandleVisibility', 'off');

    % Mean line
    h(iPair) = plot(time, meanERP, ...
        'Color', colors{iPair}, ...
        'LineStyle', lineStyles{iPair}, ...
        'LineWidth', 2);
end

yline(0, 'k-','HandleVisibility', 'off');
order = [2 1 4 3 5];
legend(h(order), condLabels(order), 'Location', 'best');
xlabel('Time (s)');
xline(0, 'k--', 'HandleVisibility', 'off');
ylabel('Amplitude (\muV)');
box off;
set(gca, 'FontSize', 15);
hold off;
set(gcf, 'Units', 'centimeters', 'Position', [2 2 18 12]);
%exportgraphics(gcf, fPath, 'Resolution', 300);
exportgraphics(gcf, [fPath, '_legend.png'], 'Resolution', 300);
exportgraphics(gcf, [fPath(1:end-4) '.pdf'], 'ContentType', 'vector');


% sort by participant number (not by string, to avoid '10' < '2' issues)
[~, sortIdx] = sort(double(T.Subject));
T = T(sortIdx, :);

% export as .csv for easy inspection outside MATLAB
writetable(T, 'P:\Sein_Jeung\Project_Fold_Rotation\Results\grand_table.csv');

