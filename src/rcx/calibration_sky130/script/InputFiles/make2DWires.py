import sys
import os

INPUTFILE_DIR = "/home/rickysuave/Documents/OSUClasses/VLSILab/FasterCap_main/InputFiles/"


class Wire():

    def __init__(self, width, thickness, metal, sublayer, diel_flag):
        self.width = width
        self.thickness = thickness
        self.metal = metal
        self.sublayer = sublayer
        self.diel_flag = diel_flag

    def __makeHeader(self, fileObject):
        # first lines of file
        line = "* {}umx{}um square\n".format(self.width, self.thickness)
        fileObject.write(line)

        line = "* Layer of square: Metal {}_{}\n".format(self.metal, self.sublayer)
        fileObject.write(line)

        line = "* segment name\t| coordinates of one segment from point to point\n*\n"
        fileObject.write(line)

        return 1

    def __makeSquare(self, fileObject, wirename, side):

        if(self.diel_flag == 1):
            line = "* bottom segment\n"
            fileObject.write(line)
            line = "S {}\t\t0.0 0.0  {} 0.0\n".format(wirename, self.width)
            fileObject.write(line)

            line = "* right segment\n"
            fileObject.write(line)
            line = "S {}\t\t{} 0.0  {} {}\n".format(wirename, self.width, self.width, self.thickness)
            fileObject.write(line)

            line = "* top segment\n"
            fileObject.write(line)
            line = "S {}\t\t{} {}  0.0 {}\n".format(wirename, self.width, self.thickness, self.thickness)
            fileObject.write(line)

            line = "* left segment\n"
            fileObject.write(line)
            line = "S {}\t\t0.0 {}  0.0 0.0\n".format(wirename, self.thickness)
            fileObject.write(line)
        else:
            if side == 0:
                line = "* bottom segment\n"
                fileObject.write(line)
                line = "S {}\t\t0.0 0.0  {} 0.0\n".format(wirename, self.width)
                fileObject.write(line)
            elif side == 1:
                line = "* right segment\n"
                fileObject.write(line)
                line = "S {}\t\t{} 0.0  {} {}\n".format(wirename, self.width, self.width, self.thickness)
                fileObject.write(line)
            elif side == 2:
                line = "* top segment\n"
                fileObject.write(line)
                line = "S {}\t\t{} {}  0.0 {}\n".format(wirename, self.width, self.thickness, self.thickness)
                fileObject.write(line)
            elif side == 3:
                line = "* left segment\n"
                fileObject.write(line)
                line = "S {}\t\t0.0 {}  0.0 0.0\n".format(wirename, self.thickness)
                fileObject.write(line)

        return 1

    def createFile(self, directory, filename):
        # make the necessary directory
        path = os.path.join(INPUTFILE_DIR, directory)

        if(not os.path.exists(path)):
            os.mkdir(path)
            print("Created directory: {}".format(directory))

        for i in range(0,4):

            if (self.diel_flag == 1):
                side = "whole"
            elif i == 0:
                side = "bottom"
            elif i == 1:
                side = "right"
            elif i == 2:
                side = "top"
            elif i == 3:
                side = "left"
            else:
                printf("Error in for loop\n")
                return -1


            # make the wire text file
            if(self.diel_flag == 1):
                fullfilename = "{}/{}.txt".format(path, filename)
            else:
                fullfilename = "{}/{}_{}.txt".format(path, filename, side)

            try:
                file = open(fullfilename, "x")
            except:
                print("Failed to create {}".format(fullfilename))
                return -1

            print("Created file: {}".format(fullfilename))

            if(self.__makeHeader(file)):
                print("Added header to file")
            else:
                print("Failed to add header")
                return -1

            if (metal > 0):
                index = filename.index("_M")
            elif (metal == 0):
                index = filename.index("_P")

            wirename = filename[:index+3]
            print("Wirename: {}".format(wirename))

            if(self.__makeSquare(file, wirename, i)):
                print("Finished {} segment".format(side))
            else:
                print("Failed to add {} segment".format(side))
                return -1

            file.close()

            if(self.diel_flag):
                return 1

def parseUM(measurement):

    line = ""

    index = measurement.index(".")
    if(index <= 0 or len(measurement) > 8 or len(measurement) < 3):
        printf("Error in measurement. Incorrect format")
        return -1

    for i in range(0, len(measurement)):
        if(i == index):
            continue
        line = line + measurement[i]

    return line

def parseMetal(metal):


    index = metal.index("_")
    if(index <= 0 or len(metal) > 3 or len(metal) < 3):
        printf("Error in metal. Incorrect format\n")
        printf("Metal must be in format metal_sublayer\n")
        printf("Ex: 5_2 will give metal layer 5 with sublayer 2")
        return -1

    met = int(metal[0])
    sublayer = int(metal[2])

    return met, sublayer;

if __name__ == "__main__":

    if(len(sys.argv) != 4 and len(sys.argv) != 5):
        print("Usage: make2DWires.py <width> <thickness> <metal layer> <optional flag: -dielectric>")
        print("** Note ** Width and Thickness need to be in micrometers in the format x.x")
        print("If smaller than micrometers make sure to lead with a zero and always append a zero if a whole number")
        print("Example: 14um = 14.0 and 1.2nm = 0.0012")
        print("Also metal layers are between 0 (polysubstrate) and 7_5 (metal 7 sublayer 5)")
        exit()

    width, thickness = sys.argv[1:3]
    metal, sublayer = parseMetal(sys.argv[3])

    parseWidth = parseUM(width)
    parseThickness = parseUM(thickness)
    if(parseWidth == -1 or parseThickness == -1):
        exit()

    if(metal == 0):
        directory = "P1"
    elif(metal < 8 and metal > 0):
        directory = "M{}".format(metal)
    else:
        print("Error in metal. Not in between 0 and 7")
        exit()

    if(len(sys.argv) == 5):
        diel = sys.argv[4]
        if(diel.index("-dielectric") == -1):
            print("Error in flag. Only -dielectric flag is allowed")
            exit()
        diel_flag = 1
        name = "dielectric"
    else:
        diel_flag = 0
        name = "wire"


    filename = "{}_{}_{}_W{}_T{}".format(name, directory, sublayer, parseWidth, parseThickness)

    # create an empty wire object
    wire = Wire(width, thickness, metal, sublayer, diel_flag)

    # create file 
    wire.createFile(directory, filename)