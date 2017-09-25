%% 22/09/2017 Miroslav Gasparek

% Script for modeling communication in liposome sensor-reporter system in
% BioSIMI modeling toolbox

% Sample for single vesicle with toggle switch
clc
clear
% close all
%% Reporter vesicle with toggle switch
% Initially aTc with concentration of 1000 nM is added
% Initial internal concentration of IPTG is 0
% IPTG diffuses into vesicle and causes the change of states of the switch
% define plasmid concentration
%{
ptet_DNA = 4; % nM
placI_DNA = 1; % nM

% set up the tubes
tube1 = txtl_extract('E30VNPRL');
tube2 = txtl_buffer('E30VNPRL');
tube3 = txtl_newtube('genetics_switch');

% add dna to tube3
dna_lacI = txtl_add_dna(tube3,'ptet(50)', 'utr1(20)', 'lacI(647)', ptet_DNA, 'plasmid');
dna_tetR = txtl_add_dna(tube3, 'plac(50)', 'utr1(20)', 'tetR(647)', placI_DNA, 'plasmid');
dna_deGFP = txtl_add_dna(tube3, 'ptet(50)', 'rbs(20)', 'deGFP(1000)', ptet_DNA, 'plasmid');
dna_deCFP = txtl_add_dna(tube3, 'placI(50)', 'rbs(20)', 'deCFP(1000)', placI_DNA, 'plasmid');

% combine extact, buffer and dna into one tube
Toggle = txtl_combine([tube1, tube2, tube3]);

% add inducers
txtl_addspecies(Toggle, 'aTc',0);
txtl_addspecies(Toggle, 'IPTG',1000);

%% Make subsystem of toggle switch

Toggle_Subsystem = BioSIMI_make_subsystem(Toggle,{'IPTG','aTc'},'protein deGFP*','Toggle_Subsystem')
Toggle = BioSIMI_assemble(Toggle_Subsystem,'Toggle')

simdata = BioSIMI_runsim(Toggle,8*60*60)
BioSIMI_plot(Toggle,simdata,'protein deCFP*')
%}
%%
clc
clear
%% Reporter vesicle with toggle switch
% Initially aTc with concentration of 1000 nM is added
% Initial internal concentration of IPTG is 0
% IPTG diffuses into vesicle and causes the change of states of the switch
% define plasmid concentration
ptet_DNA = 4; % nM
placI_DNA = 1; % nM

% set up the tubes
tube1 = txtl_extract('E30VNPRL');
tube2 = txtl_buffer('E30VNPRL');
tube3 = txtl_newtube('genetics_switch');

% add dna to tube3
dna_lacI = txtl_add_dna(tube3,'ptet(50)', 'utr1(20)', 'lacI(647)', ptet_DNA, 'plasmid');
dna_tetR = txtl_add_dna(tube3, 'plac(50)', 'utr1(20)', 'tetR(647)', placI_DNA, 'plasmid');
dna_deGFP = txtl_add_dna(tube3, 'ptet(50)', 'rbs(20)', 'deGFP(1000)', ptet_DNA, 'plasmid');
dna_deCFP = txtl_add_dna(tube3, 'placI(50)', 'rbs(20)', 'deCFP(1000)', placI_DNA, 'plasmid');

% combine extact, buffer and dna into one tube
Toggle = txtl_combine([tube1, tube2, tube3]);

% add inducers
txtl_addspecies(Toggle, 'aTc',0);
txtl_addspecies(Toggle, 'IPTG',1000);
%%
Toggle_Subsystem = BioSIMI_make_subsystem(Toggle,{'IPTG','aTc'},'protein deGFP*','Toggle_Subsystem')
Toggle = BioSIMI_assemble(Toggle_Subsystem,'Toggle')

FacDiffOut = BioSIMI_make_subsystem('FacDiffOut','input','output','FacDiffOut')
vesicle = BioSIMI_connect_new_object('vesicle',{'int','ext'},Toggle,FacDiffOut,'vesicle')

DiffIn = BioSIMI_make_subsystem('DiffusionIn','input','output','DiffIn')
rename(DiffIn.ModelObject.Species(1),'aTcint')
rename(DiffIn.ModelObject.Species(2),'aTcext')
BioSIMI_add_subsystem(vesicle.ModelObject,{'int','ext'},DiffIn)
vesicle
FinalSystem = BioSIMI_connect(vesicle.ModelObject,'int',DiffIn,vesicle,'FinalSystem')
simdata = BioSIMI_runsim(FinalSystem,8*60*60)
BioSIMI_plot(FinalSystem,simdata)

% e1 = addevent(Toggle.ModelObject,'time>=2*60*60','aTc = 1000')
% Toggle.ModelObject.Events

%%
figHandles = findobj('Type', 'figure');
for i = 1:size(figHandles,1)
allaxes(i) = findall(figHandles(i), 'type', 'axes');
allaxes(i).YLim = [0 1000];
end


%{
FacDiffOut = BioSIMI_make_subsystem('FacDiffOut','input','output','FacDiffOut')
vesicle = BioSIMI_connect_new_object('vesicle',{'int','ext'},Toggle,FacDiffOut,'vesicle')

simdata = BioSIMI_runsim(vesicle,8*60*60)
BioSIMI_plot(vesicle,simdata)


DiffIn = BioSIMI_make_subsystem('DiffusionIn','input','output','DiffIn')
rename(DiffIn.ModelObject.Species(1),'IPTGint')
rename(DiffIn.ModelObject.Species(2),'IPTGext')
BioSIMI_add_subsystem(vesicle.ModelObject,{'int','ext'},DiffIn)
FinalSystem = BioSIMI_connect(vesicle.ModelObject,'int',DiffIn,vesicle,'FinalSystem')
simdata = BioSIMI_runsim(FinalSystem,14*60*60)
BioSIMI_plot(FinalSystem,simdata)
%}