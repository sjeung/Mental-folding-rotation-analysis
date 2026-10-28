EEG = pop_loadset('P:\Sein_Jeung\Project_Fold_Rotation\Data\02_raw-EEGLAB\sub-5\sub-5_FR_EEG.set');

% 1. Remove the BrainVision prefix BEFORE looking up locations
for i = 1:numel(EEG.chanlocs)
    EEG.chanlocs(i).labels = regexprep( ...
        EEG.chanlocs(i).labels, '^BrainVision RDA_', '');
end

% 2. Match cleaned labels to standard electrode locations
locFile = 'P:\Sein_Jeung\Tools\eeglab2025.1.0\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp';
EEG = pop_chanedit(EEG, 'lookup', locFile);

% Place VEOG below the right eye
idxVEOG = find(strcmpi({EEG.chanlocs.labels}, 'VEOG'));
assert(numel(idxVEOG) == 1, 'VEOG channel not found uniquely.');

EEG.chanlocs(idxVEOG).X = 0.30;
EEG.chanlocs(idxVEOG).Y = 0.95;
EEG.chanlocs(idxVEOG).Z = 0;

EEG.chanlocs = convertlocs(EEG.chanlocs, 'cart2all');

% 4. Check that scalp channels have coordinates
for i = 1:numel(EEG.chanlocs)
    fprintf('%-6s X=%7.3f Y=%7.3f Z=%7.3f\n', ...
        EEG.chanlocs(i).labels, ...
        EEG.chanlocs(i).X, EEG.chanlocs(i).Y, EEG.chanlocs(i).Z);
end

% Plot scalp electrodes only, excluding VEOG
figure;
topoplot([], EEG.chanlocs, ...
    'electrodes', 'labels', ...
    'plotchans', find(~strcmpi({EEG.chanlocs.labels}, 'VEOG')), ...
    'efontsize', 14, ...
    'headrad', 'rim');

title('EEG electrode locations', 'FontSize', 16);