from __future__ import absolute_import
from __future__ import print_function
from __future__ import division

import os
import sys
import random
import optparse

if 'SUMO_HOME' in os.environ:
    tools = os.path.join(os.environ['SUMO_HOME'], 'tools')
    assign = os.path.join(tools, 'assign')
    sys.path.append(tools)
    sys.path.append(assign)
else:
    sys.exit("please declare environment variable 'SUMO_HOME'")

import sumolib

TRIP_SUFFIX = ".trips.xml"

def get_options(args=None):
    # add options for matlab calls
    optParser = optparse.OptionParser()
    # for example "city_cross_4lanes";
    optParser.add_option("-n", "--net-file", dest="netFile",
                         help="define the path of net file")
    optParser.add_option("-e", "--end", type="float",
                         default=180, help="end time (default 180)")
    optParser.add_option("-o", "--output-tripfile", dest="tripFile",
                         default="trips", help="define trip file name")
    optParser.add_option("--pedestrians", action="store_true", default=False,
                         help="create a person file with person trips")
    optParser.add_option("-v", "--vehicle-class",
                         dest="vClass", default="passenger", help="define vehicle type")
    optParser.add_option("-p", "--probability", dest="probability", type="float", default=0.1,
                         help="probability of generating a vehicle in a node in each time step")
    (options, args) = optParser.parse_args(args=args)

    if options.pedestrians:
        options.vclass = 'pedestrians'

    return options


def mergeDictList(dictList):

    def mergeTwoDict(x, y):
        z = x.copy()
        z.update(y)
        return z

    if not dictList:
        return {}
    elif len(dictList) == 1:
        return dictList[0]
    elif len(dictList) == 2:
        return mergeTwoDict(dictList[0], dictList[1])
    else:
        anchor = int(len(dictList)*0.5)
        return mergeTwoDict(mergeDictList(dictList[0:anchor]), mergeDictList(dictList[anchor:]))


def reachable_edge(sumoNet, edgeID, visitedNodes=None, layer=0):
    if not sumoNet.hasEdge(edgeID):
        return {}
    edge = sumoNet.getEdge(edgeID)
    sourceNode = edge.getFromNode()
    sinkNode = edge.getToNode()
    if not edge.getOutgoing():
        return {}
    if not visitedNodes:
        visitedNodes = [sinkNode]
    edgeStep = {}
    for nextEdge in edge.getOutgoing():
        if nextEdge.getToNode() != sourceNode:
            edgeStep[nextEdge] = layer
    edgeStepList = [edgeStep]
    layer = layer+1
    for nextEdge in edge.getOutgoing():
        if nextEdge.getToNode() not in visitedNodes and nextEdge.getToNode() != sourceNode:
            visitedNodes.append(nextEdge.getToNode())
            newEdgeStep = reachable_edge(
                sumoNet, nextEdge.getID(), visitedNodes, layer)
            edgeStepList.append(newEdgeStep)
    return mergeDictList(edgeStepList)


def writeTripXml(sumoNet, options):
    random.seed(131071)
    objNum = 0
    with open(options.tripFile+TRIP_SUFFIX, 'w') as trips:
        print("<routes>", file=trips)
        if not options.pedestrians:
            print("    <vType id=\"{}\" vClass=\"{}\"/>".format(options.vClass, options.vClass), file=trips)
        for t in range(int(options.end)):
            for edge in sumoNet.getEdges():
                reachableDict = reachable_edge(sumoNet, edge.getID())
                reachableDict[edge]=0
                for reachableEdge in reachableDict:
                    # trip generation probability
                    # defined here
                    if random.uniform(0, 1) < options.probability:
                        if options.pedestrians:
                            print("    <person id=\"{}\" depart=\"{}\" departPos=\"random\">".format('ped'+str(objNum), t), file=trips)
                            print("        <walk from=\"{}\" to=\"{}\" arrivalPos=\"random\"/>".format(edge.getID(), reachableEdge.getID()), file=trips)
                            print("    </person>", file=trips)
                        else:
                            print("    <trip id=\"{}\" depart=\"{}\" from=\"{}\" to=\"{}\" type=\"{}\"/>".format(
                                options.vClass+str(objNum), t, edge.getID(), reachableEdge.getID(), options.vClass), file=trips)
                        objNum = objNum+1
        print("</routes>",file=trips)
        trips.close()


def main(options):
    net = sumolib.net.readNet(options.netFile)
    writeTripXml(net, options)
    '''
    test()
    '''


if __name__ == "__main__":
    if not main(get_options()):
        sys.exit(1)
