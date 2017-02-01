
def get_well(plate,index):
    return plate[index]

def get_calibration_file_path(instrument):
    return instrument._get_calibration_file_path()

def get_calibration(instrument):
    return instrument._get_calibration()