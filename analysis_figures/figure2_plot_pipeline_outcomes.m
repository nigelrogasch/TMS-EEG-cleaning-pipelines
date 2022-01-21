% ##### PLOT FIGURE 2 #####

% This script generates figure 2 from the manuscript which compares
% grand average butterfly plots from the TEPs following step 2, step 3, and
% step 4 in the respective pipelines.

% Author: Nigel Rogasch, University of Adelaide, 2021

clear; close all; clc;

% Load name
loadName = 'model_comparison';

% Condition name
condName = {'FastICA','SOUND','Model'};

% Data path
pathIn = '/projects/kg98/Mana/decay/highIntensity_separateBlocks_withTMSPulse/';
pathOut = '/projects/kg98/Nigel/TMS-EEG_cleaning_pipeline/figures/';

% EEGLAB
addpath(genpath('/projects/kg98/Mana/Scripts/Toolboxes/eeglab14_1_2b/'));
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; close;


fig = figure('color','w');
set(gcf,'position',[250,60,850,760]);

% Load data
load([pathIn,loadName,'_step2.mat']);

time = -1000:0.1:999.9;
[~,t1] = min(abs(time - -500));
[~,t2] = min(abs(time - -3));
[~,t3] = min(abs(time- 11));
[~,t4] = min(abs(time - 500));

subplot(3,3,4)

plot(time(t1:t2),mean(tep(:,t1:t2,:),3),'k');hold on;
plot(time(t3:t4),mean(tep(:,t3:t4,:),3),'k');

% Channel 21 = FC1
plot(time(t1:t2),mean(tep(21,t1:t2,:),3),'r','linewidth',2);
plot(time(t3:t4),mean(tep(21,t3:t4,:),3),'r','linewidth',2);

plot([0,0],[-20,20],'k--');

set(gca,'xlim',[-50,250],'ylim',[-20,20],'tickdir','out','box','off','linewidth',1.5);
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
title('Raw');

% Load data
load([pathIn,loadName,'_step3.mat']);

c = get(0, 'DefaultAxesColorOrder');

time = -500:0.1:499.9;
[~,t1] = min(abs(time - -500));
[~,t2] = min(abs(time - -3));
[~,t3] = min(abs(time- 11));
[~,t4] = min(abs(time - 500));

pi = 2:3:8;

for cx = 1:length(condition)
    
    subplot(3,3,pi(cx))
    
    plot(time(t1:t2),mean(tep.(condition{cx})(:,t1:t2,:),3),'color',c(cx,:));hold on;
    plot(time(t3:t4),mean(tep.(condition{cx})(:,t3:t4,:),3),'color',c(cx,:));
    
    plot(time(t1:t2),mean(tep.(condition{cx})(21,t1:t2,:),3),'k','linewidth',2);
    plot(time(t3:t4),mean(tep.(condition{cx})(21,t3:t4,:),3),'k','linewidth',2);
    
    plot([0,0],[-20,20],'k--');
    
    set(gca,'xlim',[-50,250],'ylim',[-20,20],'tickdir','out','box','off','linewidth',1.5);
    xlabel('Time (ms)');
    ylabel('Amplitude (\muV)');
    title(['Mid ',condName{cx},' pipeline']);
    
end

% Load data
load([pathIn,loadName,'_step4.mat']);

time = -500:1:499;
[~,t1] = min(abs(time - -500));
[~,t2] = min(abs(time - -3));
[~,t3] = min(abs(time- 11));
[~,t4] = min(abs(time - 500));

pi = 3:3:9;

for cx = 1:length(condition)
    
    subplot(3,3,pi(cx))
    
    plot(time(t1:t2),mean(tep.(condition{cx})(:,t1:t2,:),3),'color',c(cx,:));hold on;
    plot(time(t3:t4),mean(tep.(condition{cx})(:,t3:t4,:),3),'color',c(cx,:));
    
    plot(time(t1:t2),mean(tep.(condition{cx})(21,t1:t2,:),3),'k','linewidth',2);
    plot(time(t3:t4),mean(tep.(condition{cx})(21,t3:t4,:),3),'k','linewidth',2);
    
    plot([0,0],[-20,20],'k--');
    
    set(gca,'xlim',[-50,250],'ylim',[-20,20],'tickdir','out','box','off','linewidth',1.5);
    xlabel('Time (ms)');
    ylabel('Amplitude (\muV)');
    title(['End ',condName{cx},' pipeline']);
    
end

saveas(fig,[pathOut,'butterfly_plot_all.png']);
saveas(fig,[pathOut,'figure2.png']);