%% Test how I would construct a script to run a job using saved configs

%% Initialize Liquid Handler

LH = LiquidHandler(savedLH);

%% Home Axes
LH.Com.homeAxis('ZAB')
LH.Com.homeAxis('XY')

%% Open up LH GUI
LHgui(LH)


%% See container positions

firstTip = LH.Deck.p200tips.get_rel_child_coord('A1','Left')
LH.Com.moveToZzero('XYZ',firstTip)
firstWell = LH.Deck.mp1.get_rel_child_coord('A1','Left')

LH.Com.moveToZzero('XYZ',firstWell)

LH.Com.moveToZzero('XYZ',LH.Deck.trash.get_rel_child_coord('A1','Left'))

%% try other things
LH.Com.moveToZzero('XYZ',LH.Deck.p200tips.get_rel_child_coord('B1','Left'))
LH.Com.moveToZzero('XYZ',LH.Deck.mp1.get_rel_child_coord('B1','Left'))
LH.Com.moveToZzero('XYZ',LH.Deck.mp1.get_rel_child_coord('H12','Left'))
LH.Com.moveToZzero('XYZ',LH.Deck.trash.get_rel_child_coord('A1','Left'))

%% test pipette volume pickup

LH.ejectLiq('Left',3)
LH.testPickupVol('Left',200)

LH.testPickupVol('Left',100)
LH.testPickupVol('Left',50)