
def get_well(plate,index):
    return plate[index]

def get_calibration_file_path(instrument):
    return instrument._get_calibration_file_path()

def get_calibration(instrument):
    return instrument._get_calibration()

def build_calibration_data(instrument):
    return instrument._build_calibration_data()

def get_current_head_position(robot):
    return robot._driver.get_head_position()['current']