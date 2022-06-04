# @noindex

import tosclib as tosc
from pathlib import Path
import xml.etree.ElementTree as ET

FX_PARAM_LIMIT = 10

class FX:
    def __init__(self, inputPath):
        with open(inputPath, "r") as file:
            self.name = ET.fromstring(file.read())
        self.params = self.name.find("params")

def main(inputFile, outputFile):

    fx = FX(inputFile)

    root = tosc.createTemplate()
    base = tosc.ElementTOSC(root[0])
    base.createProperty("s", "name", "template")
    base.setFrame((0, 0, 1920, 1080))

    # Group container for the faders
    group = tosc.ElementTOSC(base.createChild("GROUP"))
    group.createProperty("s", "name", fx.name.text)
    group.setFrame((420, 0, 1080, 1080))
    group.setColor((0.25, 0.25, 0.25, 1))

    # Create faders
    width = int(group.getPropertyParam("frame", "w").text) / FX_PARAM_LIMIT
    msg = tosc.OSC(
        path=[
            tosc.Partial(),  # Default is the constant '/'
            tosc.Partial(type="PROPERTY", value="parent.name"),
            tosc.Partial(),
            tosc.Partial(type="PROPERTY", value="name"),
        ]
    )

    for i, param in enumerate(fx.params):
        index = int(param.attrib["index"])
        fader = tosc.ElementTOSC(group.createChild("FADER"))
        fader.createProperty("s", "name", param.text)
        fader.setFrame((width * i, 0, width, 1080))
        fader.setColor((i / FX_PARAM_LIMIT, 0, 1 - i / FX_PARAM_LIMIT, 1))
        fader.createOSC(msg)
        
        if index == FX_PARAM_LIMIT:
            break

    tosc.write(root, outputFile)


if __name__ == "__main__":
    file = Path(RPR_GetExtState("AlbertoV5-ReaperTools", "liszt_path_1"))
    main(file, file.parent / f"{str(file.stem)}.tosc")
