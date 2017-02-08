
% Testing new class
%% Initiate OpenTrons
OT = OpenTrons;

%% Specify deck and pipettese
tiprack200 = OT.loadContainer('tiprack200','tiprack-200ul','A1');
trash = OT.loadContainer('trash','point','B2');
p200 = OT.loadPipette('p200','b',200,'min_volume',20,'trash_container',OT.trash,'tip_racks',{OT.tiprack200});

p1000 = OT.loadPipette('p1000','a',1000,'min_volume',200);
tiprack1000 = OT.loadContainer('tiprack1000','tiprack-1000ul','B3');
% tiprack1000b = OT.loadContainer('tiprack1000b','tiprack-1000ul','C3');

p1000.trash_container = trash;
% p1000.tip_racks = tiprack1000b;
p1000.add_tip_rack(tiprack1000,1);

plate24 = OT.loadContainer('plate24','24-plate','D2');

%% Calibrating positions


p200.calibrate_position(tiprack200,'A1')

% currTip = OT.helper.get_well(tiprack200,'A1');
p200.pick_up_tip([],'Now')

p200.calibrate_position(trash,'A1')
p200.drop_tip([],'Now')

p200.return_tip('Now')

p200.calibrate_position(plate24,'A1')

p200.pypette.move_to(OT.helper.get_well(plate24,'A1').bottom(),'arc',false)


p1000.calibrate_position(tiprack1000,'A3');
p1000.calibrate_position(trash,'A1');

p1000.pypette.start_at_tip(OT.helper.get_well(tiprack1000,'A3'))
p1000.pick_up_tip([],'Now')
p1000.drop_tip([],'Now')

%% Testing protocol
p200.pick_up_tip([],'Now')
p200.aspirate(100,OT.helper.get_well(plate24,'A1'),[],'Now')
p200.dispense(50,OT.helper.get_well(plate24,'A2'),[],'Now')
p200.mix(2,[],OT.helper.get_well(plate24,'A2'),[],'Now')
p200.dispense(50,OT.helper.get_well(plate24,'B1'),[],'Now')
p200.blow_out([],'Now')
p200.touch_tip([],'Now')
p200.drop_tip([],'Now')

p200.pick_up_tip()
p200.aspirate(100,OT.helper.get_well(plate24,'A1'))
p200.dispense(50,OT.helper.get_well(plate24,'A2'),1.5)
p200.dispense(50,OT.helper.get_well(plate24,'B1'),0.5)
p200.drop_tip()