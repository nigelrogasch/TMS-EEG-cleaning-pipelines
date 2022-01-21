% ##### PIPELINE STEP 3 (FASTICA_2 repeats) #####

% This script automatically removes components consistent with decay 
% artifacts following the TMS pulse on FastICA repeats.

% TMS-EEG data required for this script are generated from:
% pipeline_step3_FastICA_1_repeat.m

% Author: Nigel Rogasch, University of Adelaide, 2021

clear; close all; clc;

% Participant IDs
ID = {'121','123','126','127','129','137','138','139','142','143','145','146','147','148'};

% Data path
pathIn = '/projects/kg98/Mana/decay/highIntensity_separateBlocks_withTMSPulse/';

% EEGLAB
addpath(genpath('/projects/kg98/Mana/Scripts/Toolboxes/eeglab14_1_2b/'));
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; close;

condition = {'2','3'};

for cx = 1:length(condition)
    
    for idx = 1:length(ID)
        
        % Load the data
        filename = [ID{idx},'_FEF_Decaytest_withTMSPulse_step3_FastICA',condition{cx},'.set'];
        EEG = pop_loadset('filename',filename,'filepath',pathIn);
         
        % Run FastICA
        EEG = pop_tesa_compselect( EEG,'compCheck','off','remove','on','saveWeights','off','figSize','small','plotTimeX',[-200 500],'plotFreqX',[1 100],'freqScale','log','tmsMuscle','on','tmsMuscleThresh',8,'tmsMuscleWin',[11 30],'tmsMuscleFeedback','off','blink','off','blinkThresh',2.5,'blinkElecs',{'Fp1','Fp2'},'blinkFeedback','off','move','off','moveThresh',2,'moveElecs',{'F7','F8'},'moveFeedback','off','muscle','off','muscleThresh',-0.31,'muscleFreqIn',[7 70],'muscleFreqEx',[48 52],'muscleFeedback','off','elecNoise','off','elecNoiseThresh',4,'elecNoiseFeedback','off' );
        
        % Save the data
        filename = [ID{idx},'_FEF_Decaytest_withTMSPulse_step3_FastICA',condition{cx},'_clean.set'];
        filepath = pathIn;
        EEG = pop_saveset( EEG, 'filename',filename,'filepath',filepath);
        
    end
end

