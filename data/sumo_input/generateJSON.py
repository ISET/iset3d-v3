import json
import optparse
import os
import sys

if 'SUMO_HOME' in os.environ:
    tools = os.path.join(os.environ['SUMO_HOME'], 'tools')
    sys.path.append(tools)
else:
    sys.exit("please declare environment variable 'SUMO_HOME'")

import sumolib

JSON_SUFFIX = '.json'


def get_options(args=None):
    # add options for matlab calls
    optParser = optparse.OptionParser()
    # for example "city_cross_4lanes";
    optParser.add_option("-f", "--xml-file", dest="xmlFile",
                         help="define the name of state xml file")
    optParser.add_option("-o", "--output-json-file", dest="jsonFile",
                         default="json", help="define json file name")
    (options, args) = optParser.parse_args(args=args)
    return options


def output_file(options):
    stateGen = sumolib.xml.parse_fast_nested(options.xmlFile, 'timestep', [
                                             'time'], 'vehicle', ['id', 'x', 'y', 'z', 'angle', 'type', 'speed', 'slope'],\
                                             )
    personGen=sumolib.xml.parse_fast_nested(options.xmlFile,'timestep',['time'],'person',['id','x','y','z','angle','speed','slope'])
    stateList = list(stateGen)
    personList=list([personGen])
    WITH_Z = True
    if not stateList:
        WITH_Z=False
        stateGen = sumolib.xml.parse_fast_nested(options.xmlFile, 'timestep', [
                                                 'time'], 'vehicle', ['id', 'x', 'y', 'angle', 'type', 'speed', 'slope'])
        personGen=sumolib.xml.parse_fast_nested(options.xmlFile,'timestep',['time'],'person',['id', 'x', 'y', 'angle', 'speed', 'slope'])
        stateList = list(stateGen)
        personList=list(personGen)
    outputList = []
    minTime = -1.0
    for state in stateList:
        newInstance = {}
        # ! Important
        # y,z is fliped from SUMO to pbrt
        if WITH_Z:
            newInstance["pos"] = [float(state[1].x), float(
                state[1].z), float(state[1].y)]
        else:
            newInstance["pos"] = [float(state[1].x), 0.0, float(state[1].y)]

        newInstance["orientation"] = float(state[1].angle)
        newInstance["speed"] = float(state[1].speed)
        newInstance["name"] = state[1].id
        newInstance["slope"]=float(state[1].slope)
        newInstance["type"]=state[1].type
        if state[1].type =="passenger":
            newInstance["class"]="car"
        else:
            newInstance["class"] = state[1].type
        if float(state[0].time) <= minTime:
            if state[1].type in outputList[-1]["objects"]:
                outputList[-1]["objects"][state[1].type].append(newInstance)
            elif state[1].type=="passenger" and "car" in outputList[-1]["objects"]:
                outputList[-1]["objects"]["car"].append(newInstance)
            elif state[1].type=="passenger" and "car" not in outputList[-1]["objects"]:
                outputList[-1]["objects"]["car"]=[newInstance]
            else:
                outputList[-1]["objects"][state[1].type]=[newInstance]
        else:
            stateDict = {}
            minTime = float(state[0].time)
            stateDict["timestamp"] = minTime
            objDict = {}
            if state[1].type=="passenger":
                objDict["car"]=[newInstance]
            else:
                objDict[state[1].type] = [newInstance]
            stateDict["objects"] = objDict
            outputList.append(stateDict)

        # pedestrians
        while personList:
            if float(personList[0][0].time)<=minTime:
                person=personList.pop(0)
                newPerson={}
                if WITH_Z:
                    newPerson["pos"]=[float(person[1].x),float(person[1].z),float(person[1].y)]
                else:
                    newPerson["pos"]=[float(person[1].x),0.0,float(person[1].y)]
                newPerson["orientation"] = float(person[1].angle)
                newPerson["slope"]=float(person[1].slope)
                newPerson["speed"] = float(person[1].speed)
                newPerson["name"] = person[1].id
                newPerson["class"] = "pedestrian"
                newPerson["type"]=[]
        
                if "pedestrian" in outputList[-1]["objects"]:
                    outputList[-1]["objects"]["pedestrian"].append(newPerson)
                else:
                    outputList[-1]["objects"]["pedestrian"]=[newPerson]
            else:
                break

    with open(options.jsonFile+JSON_SUFFIX, 'w') as outfile:
        json.dump(outputList, outfile)


def main(options):
    output_file(options)


if __name__ == "__main__":
    if not main(get_options()):
        sys.exit(1)
