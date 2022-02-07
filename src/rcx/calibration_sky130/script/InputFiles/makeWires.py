import sys
import os

INPUTFILE_DIR = "/home/rickysuave/Documents/OSUClasses/VLSILab/FasterCap_main/InputFiles/"

# PROCESSFILE UNITS
LI1_THICK = 0.25
M2_THICK = 0.3
M3_THICK = 0.3
M4_THICK = 0.3
M5_THICK = 0.3
M6_THICK = 0.9

# CAP_MODEL UNITS
#LI1_THICK = 0.1
#M2_THICK = 0.36
#M3_THICK = 0.36
#M4_THICK = 0.845
#M5_THICK = 0.845
#M6_THICK = 1.26

class Wire():

    def __init__(self, width, length, metal):
        self.width = width
        self.length = length
        self.metal = metal

        if(metal == 1):
            self.thickness = LI1_THICK
        elif(metal == 2):
            self.thickness = M2_THICK
        elif(metal == 3):
            self.thickness = M3_THICK
        elif(metal == 4):
            self.thickness = M4_THICK
        elif(metal == 5):
            self.thickness = M5_THICK
        elif(metal == 6):
            self.thickness = M6_THICK
        else:
            self.thickness = -1

    def __makeHeader(self, fileObject):
        # first lines of file
        line = "* {}umx{}umx{}um wire\n".format(self.width, self.length, self.thickness)
        fileObject.write(line)

        line = "* Layer of wire: Metal {}\n".format(self.metal)
        fileObject.write(line)

        line = "* conductor name\t|  3D coordinates of the four corners\n*\n"
        fileObject.write(line)

        return 1

    def __makeCoordinates(self, fileObject, wirename):
        line = "* bottom panel\n"
        fileObject.write(line)
        line = "Q {}\t\t0.0 0.0 0.0  {} 0.0 0.0  {} {} 0.0  0.0 {} 0.0\n".format(wirename, self.width, self.width, self.length, self.length)
        fileObject.write(line)

        line = "* front panel\n"
        fileObject.write(line)
        line = "Q {}\t\t0.0 0.0 0.0  {} 0.0 0.0  {} 0.0 {}  0.0 0.0 {}\n".format(wirename, self.width, self.width, self.thickness, self.thickness)
        fileObject.write(line)

        line = "* left panel\n"
        fileObject.write(line)
        line = "Q {}\t\t0.0 0.0 0.0  0.0 {} 0.0  0.0 {} {}  0.0 0.0 {}\n".format(wirename, self.length, self.length, self.thickness, self.thickness)
        fileObject.write(line)


        line = "* top panel\n"
        fileObject.write(line)
        line = "Q {}\t\t0.0 0.0 {}  {} 0.0 {}  {} {} {}  0.0 {} {}\n".format(wirename, self.thickness, self.width, self.thickness, self.width, self.length, self.thickness, self.length, self.thickness)
        fileObject.write(line)

        line = "* right panel\n"
        fileObject.write(line)
        line = "Q {}\t\t{} 0.0 0.0  {} 0.0 {}  {} {} {}  {} {} 0.0\n".format(wirename, self.width, self.width, self.thickness, self.width, self.length, self.thickness, self.width, self.length)
        fileObject.write(line)

        line = "* back panel\n"
        fileObject.write(line)
        line = "Q {}\t\t0.0 {} 0.0  {} {} 0.0  {} {} {}  0.0 {} {}\n".format(wirename, self.length, self.width, self.length, self.width, self.length, self.thickness, self.length, self.thickness)
        fileObject.write(line)

        return 1

    def createFile(self, directory, filename):
        # make the necessary directory
        path = os.path.join(INPUTFILE_DIR, directory)

        if(not os.path.exists(path)):
            os.mkdir(path)
            print("Created directory: {}".format(directory))

        # make the wire text file
        fullfilename = "{}/{}".format(path, filename)
        try:
            file = open(fullfilename, "x")
        except:
            print("Failed to create {}".format(filename))
            return -1

        print("Created file: {}".format(fullfilename))

        if(self.__makeHeader(file)):
            print("Added header to file")
        else:
            print("Failed to add header")
            return -1

        # parse out .txt so file can use name
        index = filename.index(".txt")
        wirename = filename[0:index]

        if(self.__makeCoordinates(file, wirename)):
            print("Finished coordinates")
        else:
            print("Failed to add coordinates")
            return -1

        file.close()

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

if __name__ == "__main__":

    if(len(sys.argv) != 4):
        print("Usage: makeWires.py <width> <length> <metal layer>")
        print("** Note ** Width and Length need to be in micrometers in the format x.x")
        print("If smaller than micrometers make sure to lead with a zero and always append a zero if a whole number")
        print("Example: 14um = 14.0 and 1.2nm = 0.0012")
        print("Also metal layers are between 1 and 6")
        exit()

    width, length = sys.argv[1:3]
    metal = int(sys.argv[3])

    parseWidth = parseUM(width)
    parseLength = parseUM(length)
    if(parseWidth == -1 or parseLength == -1):
        exit()

    if(metal == 1):
        directory = "LI1"
    elif(metal < 7 and metal > 1):
        directory = "M{}".format(metal)
    else:
        print("Error in metal. Not in between 1 and 6")
        exit()

    filename = "wire_{}_W{}_L{}.txt".format(directory, parseWidth, parseLength)

    # create an empty wire object
    wire = Wire(width, length, metal)

    # create file 
    wire.createFile(directory, filename)