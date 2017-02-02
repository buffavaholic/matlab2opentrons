%%% pretend to be a microscope manually

%% Prep first addition
globalTipNum = 14;
currTip = mod.get_well(tiprack1000,int8(globalTipNum));
globalTipNum = globalTipNum+1;
p1000.pick_up_tip(currTip);
source = mod.get_well(tuberack2ml,'C1');
dest = mod.get_well(plate24,'B2');
vol = 200;
p1000.aspirate(vol,source);
p1000.move_to(dest.top());

robot.run()

robot.clear_commands();

%% submit for addition

rel_pos=firstHole.from_center(pyargs('x',0,'y',0,'z',-1,'reference',plate24));
coords = p1000.calibrator.convert(plate24,rel_pos);
% convert coords to VectorValues
coordVals = coords.to_tuple();

delta_x = 18*0;
delta_y = 18*0;

newCoord = py.tuple({coordVals.x+delta_x,coordVals.y+delta_y,coordVals.z});

tipCoord = py.tuple({plate24,rel_pos});

p1000.calibrate_position(tipCoord,newCoord);

robot.clear_commands()

p1000.dispense(vol,dest);
p1000.mix(int8(2),200);
p1000.drop_tip();

robot.run()

robot.clear_commands();

%% Prep next addition

currTip = mod.get_well(tiprack1000,int8(globalTipNum));
globalTipNum = globalTipNum+1;
p1000.pick_up_tip(currTip);
source = mod.get_well(tuberack2ml,'C1');
dest = mod.get_well(plate24,'C2');
vol = 200;
p1000.aspirate(vol,source);
p1000.move_to(dest.top());

robot.run()

%% Dispatch next addition

robot.clear_commands();

rel_pos=firstHole.from_center(pyargs('x',0,'y',0,'z',-1,'reference',plate24));
coords = p1000.calibrator.convert(plate24,rel_pos);
% convert coords to VectorValues
coordVals = coords.to_tuple();

delta_x = 18*0;
delta_y = 18*1;

newCoord = py.tuple({coordVals.x+delta_x,coordVals.y+delta_y,coordVals.z});

tipCoord = py.tuple({plate24,rel_pos});

p1000.calibrate_position(tipCoord,newCoord);

robot.clear_commands()

p1000.dispense(vol,dest);
p1000.mix(int8(2),200);
p1000.drop_tip();

robot.run()