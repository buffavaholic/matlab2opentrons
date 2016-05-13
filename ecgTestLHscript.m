%% Test how I would construct a script to run a job

%% Initialize Liquid Handler

LH = LiquidHandler;

%% Add pipettes to head
LH.Head.setPipette('Left','p200')
LH.Head.setPipette('Right','p1000')

%% Add containers to deck

LH.Deck.addContainer('mp1','B2','microplate_96_deep_well');
LH.Deck.addContainer('p200tips','A2','tiprack_200');
LH.Deck.addContainer('trash','C3','trash');

%% Open up LH GUI
LHgui(LH)

%% Here is where I would have to calibrate containers

LH.Deck.p200tips.calibrate([21,245.5,114],'Left')
LH.Deck.mp1.calibrate([113.5,245,122],'Left')
LH.Deck.trash.calibrate([233,78,91],'Left')

%% re home then check calibration

firstTip = LH.Deck.p200tips.get_rel_child_coord('A1','Left')
LH.Com.moveToZzero('XYZ',firstTip)
firstWell = LH.Deck.mp1.get_rel_child_coord('A1','Left')

LH.Com.moveToZzero('XYZ',firstWell)

LH.Com.moveToZzero('XYZ',LH.Deck.trash.get_rel_child_coord('A1','Left'))

%% check child coordinates
nextWell = LH.Deck.B2.get_rel_child_coord('A2','Left')

LH.Com.moveToZheight('XYZ',nextWell,nextWell(3)-30)

nextTip = LH.Deck.A2.get_rel_child_coord('B1','Left')

LH.Com.moveToZzero('XYZ',nextTip)
% LH.Com.moveToZheight('XYZ',nextTip,nextTip(3)-30)

nextWell = LH.Deck.B2.get_rel_child_coord('A2','Left')

LH.Com.moveToZzero('XYZ',nextWell)

nextWell = LH.Deck.B2.get_rel_child_coord('H12','Left')

LH.Com.moveToZzero('XYZ',nextWell)