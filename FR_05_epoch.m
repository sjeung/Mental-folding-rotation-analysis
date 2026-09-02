function FR_05_epoch(subject)

% load bemobil config
FR_bemobil_config

%% epoch the data

%% filepaths
input_filepath  = [bemobil_config.study_folder '\' bemobil_config.single_subject_analysis_folder  bemobil_config.filename_prefix num2str(subject)];
output_filepath = [bemobil_config.study_folder '\' bemobil_config.epoched_folder  bemobil_config.filename_prefix num2str(subject)];

if ~isfolder(output_filepath)
    mkdir(output_filepath);
end

% load data
EEG = pop_loadset('filename', ['sub-' num2str(subject) '_eyeIC_cleaned.set'] ,'filepath', input_filepath);
EEG = eeg_checkset(EEG);

%          difficulty   angle       match
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
condTexts       = {};
condTexts{1}    =  'fold:4;angle:90;meet:Y;';
condTexts{2}    =  'fold:4;angle:90;meet:N;';
condTexts{3}    =  'fold:4;angle:40;meet:Y;';
condTexts{4}    =  'fold:4;angle:40;meet:N;';
condTexts{5}    =  'fold:6;angle:90;meet:Y;';
condTexts{6}    =  'fold:6;angle:90;meet:N;';
condTexts{7}    =  'fold:6;angle:40;meet:Y;';
condTexts{8}    =  'fold:6;angle:40;meet:N;';
condTexts{9}    =  'fold:0;angle:0;meet:Y;';
condTexts{10}   =  'fold:0;angle:0;meet:N;';
nets            = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'};
BEH         = cell2table(cell(0,8), 'VariableNames', {'Count', 'Cond', 'Fold', 'Angle', 'Parity','Net','Correct', 'RT'});
epoches     = [];  
nEvents     = numel(EEG.event);
Ti          = 0; % initialize trial count
for Ei = 1:nEvents
    if contains(EEG.event(Ei).type, 'fold:')
        fold                = extractBetween(EEG.event(Ei).type, 'fold:', ';');
        angle               = extractBetween(EEG.event(Ei).type, 'angle:', ';');
        parity              = extractBetween(EEG.event(Ei).type, 'meet:', ';');
        net                 = extractBetween(EEG.event(Ei).type, 'net:', ';');
        cond                = find(strcmp(extractBetween(EEG.event(Ei).type, '','net'), condTexts));
        
        Ti = Ti +1;
        BEH(Ti,:) = { ...
            Ti, ...
            cond, ... 
            str2double(fold{1}), ...
            str2double(angle{1}), ...
            strcmp(parity{1}, 'Y'), ...
            find(strcmp(net{1}, nets)), ...
            NaN, ...        % Correct (to be filled later)
            NaN };          % RT (to be filled later)
        
        % update event type
        EEG.event(Ei).type  = num2str(cond);  
        
    elseif contains(EEG.event(Ei).type, 'response_evaluation')
        correct             = extractBetween(EEG.event(Ei).type, 'evaluation:', ';');
        rt                  = extractBetween(EEG.event(Ei).type, 'rt:', ';');
        BEH.Correct(Ti) = strcmp(correct{1}, 'correct');
        BEH.RT(Ti)      = str2double(rt{1});
    end
    
    if subject == 2 && Ti == 493 % for this participant 7 trials are missing 
        BEH(Ti,:) = []; 
        break; 
    end
end

% check integrity
rt6 = BEH.RT(BEH.Fold == 6);
rt4 = BEH.RT(BEH.Fold == 4);
rt6 = rt6(~isnan(rt6));
rt4 = rt4(~isnan(rt4));
meanRT = [mean(rt6), mean(rt4)];
semRT = [std(rt6)/sqrt(length(rt6)), ...
    std(rt4)/sqrt(length(rt4))];

disp([num2str(Ti) ' trials found for participant ' num2str(subject)]);
disp(['6 fold mean RT = ' num2str(meanRT(1)) ' sec, SEM = ' num2str(semRT(1))]);
disp(['4 fold mean RT = ' num2str(meanRT(2)) ' sec, SEM = ' num2str(semRT(2))]);

nTrialsInCond = nan(1,10); 
nRejectInCond = nan(1,10); 

% trial number balance 
for iCond = 1:10
    condIdx = BEH.Cond == iCond;
    if numel(find(condIdx)) ~= 50 
        disp(['WARNING : Trial number in cond ' num2str(iCond) ' = ' num2str(numel(find(condIdx)))]); 
    end
    
    accuracy = 100*numel(find(BEH.Correct(BEH.Cond == iCond)))/numel(find(BEH.Cond == iCond)); 
    
    if accuracy <= 70 
        disp(['WARNING : accuracy in cond ' num2str(iCond) ' = ' num2str(accuracy) ' %']); 
    end
    
    rt      = BEH.RT(condIdx);
    [~,tfs] = rmoutliers(rt); 
  
    % Map back to full table indices
    condIdxFull = find(condIdx);
    BEH.Reject(condIdxFull(tfs)) = true;
    incorrectIdx = condIdx & (BEH.Correct == 0 | isnan(BEH.Correct));
    BEH.Reject(incorrectIdx) = true;
    nRejectInCond(iCond) = sum(BEH.Reject(condIdx));
    nTrialsInCond(iCond) = numel(find(condIdx));
end

% count no match and match as one condition 
for iPair = 1:5 
   disp(['Trials rejected for participant ' num2str(subject) ': ' num2str(nRejectInCond(iPair*2-1) + nRejectInCond(iPair*2)) ' out of ' num2str(nTrialsInCond(iPair*2-1) +nTrialsInCond(iPair*2)) ' trials, condition pair ' num2str(iPair)])
 
   if nRejectInCond(iPair*2-1) + nRejectInCond(iPair*2) > 0.3*(nTrialsInCond(iPair*2-1) +nTrialsInCond(iPair*2))
       error('Too many trials rejected ')
   end

end

rejectVec = BEH.Reject; 
BEH(rejectVec,:)          = [];
maxRT = max(BEH.RT);

% epoch
EEG_epoched = pop_epoch(EEG, {'1','2','3','4','5','6','7','8','9','10'}, [-0.2 maxRT], 'newname', ['sub-' num2str(subject) '_epoched'],'epochinfo', 'yes');

% actually remove the trials
EEG_epoched.epoch(rejectVec)   = [];
EEG_epoched.data(:,:,rejectVec) = [];

% ensure that the behavioural struct and eeg epochs match in number
if subject == 12
    BEH(417,:) = []; % for sub 12 recording ended early - remove the last trial
elseif subject == 17
    BEH(418:419,:) = []; % for sub 17 recording ended early - remove the last two trials    
end
assert(size(BEH,1) == numel(EEG_epoched.epoch)); 
pop_saveset(EEG_epoched, 'filename', ['sub-' num2str(subject) '_' bemobil_config.epoched_filename],'filepath', output_filepath, 'savemode', 'twofiles');
save(fullfile(output_filepath, ['sub-' num2str(subject) '_RT.mat']),"BEH"); 

end




