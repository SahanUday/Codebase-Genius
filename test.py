class Rels:
    def __init__(self, from_abstraction: str, to_abstraction: str, label: str):
        self.from_abstraction = from_abstraction
        self.to_abstraction = to_abstraction
        self.label = label

rels_list = [
    Rels(from_abstraction='GeofencingEngine', to_abstraction='FirebaseACCommander', label='sends AC commands'),
    Rels(from_abstraction='ScheduleTimerManager', to_abstraction='FirebaseACCommander', label='sends AC commands'),
    Rels(from_abstraction='SmartControlAgent', to_abstraction='FirebaseACCommander', label='sends AC commands'),
    Rels(from_abstraction='SmartControlAgent', to_abstraction='SensorDataStreamer', label='receives sensor data')
]

# access the first element's label
a= rels_list[0]
print(rels_list.index(a))

