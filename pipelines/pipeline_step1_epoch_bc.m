% ##### PIPELINE STEP 1 #####

% This script epochs around the TMS pulse, baseline corrects the data and
% removes any unused channels.

% Raw TMS-EEG data required for this script are available on request from
% the authors. Note that output data from this script are available at:
% https://doi.org/10.26180/18805994.v4

% Author: Mana Biabani, University of Adelaide, 2021

clear; close all; clc;

% IDs of participants to analyse
ID = {'121','123','126','127','129','137','138','139','142','143','145','146','147','148'};

% Filename identifiers
sufix = {'FEF'};

% File path where data is stored
pathIn ='/projects/kg98/Mana/GWM/rawdata/';

% pathOut
pathOut = '/projects/kg98/Mana/GWM/Analyzed/';

% EEGLAB
addpath(genpath('/projects/kg98/Mana/Scripts/Toolboxes/eeglab14_1_2b/'));
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

for idx = 1:length(ID)
    
    % Makes a subject folder
    if ~isequal(exist([pathOut,ID{idx,1}], 'dir'),7)
        mkdir(pathOut,ID{idx,1});
    end
    
    % Clear EEG
    EEG = {};
    
    % Clear ALLEEG
    ALLEEG = [];
    
    % File path where data is stored
    filePath = [pathIn,'sub-GWM',ID{idx,1},'/TMSEEG/GWM',ID{idx,1},'_SP_',sufix{1},'/GWM',ID{idx,1},'_SP_',sufix{1}];
    
    % Load Curry files
    EEG = loadcurry( [filePath, '.dap','CurryLocations', 'False']);
    
    % Load channel locations
    EEG = pop_chanedit(EEG, 'lookup','/projects/kg98/Mana/Scripts/Toolboxes/eeglab14_1_2b/plugins/dipfit/standard_BESA/standard-10-5-cap385.elp');
    
    % Epoch around TMS pulse
    if strcmp(ID{idx,1},'104') || (strcmp(ID{idx,1},'112')&& strcmp(sufix{suf},'SHAM'))|| (strcmp(ID{idx,1},'136'))|| (strcmp(ID{idx,1},'137'))|| (strcmp(ID{idx,1},'138'))|| (strcmp(ID{idx,1},'139'))
        EEG = pop_epoch( EEG, {  '191'  }, [-1  1], 'newname', 'ep', 'epochinfo', 'yes');
    else
        EEG = pop_epoch( EEG, {  '128'  }, [-1  1], 'newname', 'ep', 'epochinfo', 'yes');
    end
    
    % Remove baseline
    EEG = pop_rmbase( EEG, [-500  -10]);
    
    % Remove unused channels
    EEG = pop_select( EEG,'nochannel',{'31' '32' 'Trigger'});
    
    % Save the original EEG locations for use in interpolation later
    EEG.allchan = EEG.chanlocs;
    
    % Label the events
    for i = 1 : EEG.trials
        EEG.event(i).type = sufix{1};
    end
    
    % save data
    EEG = pop_saveset( EEG, 'filepath',['/projects/kg98/Mana/decay/highIntensity_separateBlocks_withTMSPulse/'],'filename', [ID{idx,1} '_' sufix{1} '_Decaytest_withTMSPulse']);
    
end
