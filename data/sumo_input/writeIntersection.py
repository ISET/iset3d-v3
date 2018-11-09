from __future__ import absolute_import
from __future__ import print_function

import os
import sys
import optparse

if 'SUMO_HOME' in os.environ:
    tools = os.path.join(os.environ['SUMO_HOME'], 'tools')
    assign = os.path.join(tools, 'assign')
    sys.path.append(tools)
    sys.path.append(assign)
else:
    sys.exit("please declare environment variable 'SUMO_HOME'")

import sumolib

ADD_SUFFIX=".add.xml"
OUTPUT_SUFFIX="_traffic_light.xml"

def get_options(args=None):
    # add options for matlab calls
    optParser = optparse.OptionParser()
    # for example "city_cross_4lanes";
    optParser.add_option("-n", "--net-file", dest="netFile",
                         help="define the path of net file")
    optParser.add_option("-o", "--output-scene-type", dest="sceneType",
                         default="add", help="define sceneType")
   
    (options, args) = optParser.parse_args(args=args)

    return options

def writeAddXml(sumoNet,options):
    tls=sumoNet.getTrafficLights()
    if tls:
        with open(options.sceneType+ADD_SUFFIX,'w') as adds:
            print("<tlsStates>",file=adds)
            for tl in tls:
                print("    <timedEvent type=\"SaveTLSStates\" source=\""+tl.getID()+"\" dest=\""+options.sceneType+OUTPUT_SUFFIX+"\"/>",file=adds)
            print("</tlsStates>",file=adds)
            adds.close()

def main(options):
    net = sumolib.net.readNet(options.netFile)
    writeAddXml(net,options)


if __name__ == "__main__":
    if not main(get_options()):
        sys.exit(1)