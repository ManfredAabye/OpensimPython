import sys
import importlib

# Die .NET-Assemblies werden direkt importiert, wenn sie verfügbar sind
from OpenSim.Region.Framework.Interfaces import IRegionModule # type: ignore

class PyReloader(IRegionModule):
    upgradable = False
    regpymods = []  # Keine externen Module mehr erforderlich
    reginstances = []

    def Initialise(self, scene, configsource):
        self.scene = scene
        self.config = configsource
        scene.AddCommand(self, "py-reload", "py-reload", "...", self.cmd_py_reload)
        print(self, 'initialised with', scene)

    def PostInitialise(self):
        print(self, 'post-initialise')

    def Close(self):
        print(self, 'close')

    @property
    def Name(self):
        return "MyRegionModule"

    @property
    def IsSharedModule(self):
        return False

    def cmd_py_reload(self, modname, args):
        try:
            self.reload(modname, args)
        except Exception as e:
            print('error')
            import traceback
            traceback.print_exc()
            raise

    def reload(self, modname, args):
        print('closing modules')
        for ri in self.reginstances:
            print("found", ri, "in reginstances")
            if ri.Name in self.scene.Modules:
                print("also found in modules, so marking removed")
                ri.removed = True
                print("removing", ri.Name, "from self.scene.Modules")
                self.scene.Modules.Remove(ri.Name)
            else:
                print("not found in modules so not removing")
            ri.Close()

        self.reginstances[:] = []

        print('reloading modules & looking for region classes')
        regclasses = []
        # Keine Module mehr zum Nachladen vorhanden
        # Dies ist nur ein Platzhalter, um zu zeigen, wie man Module lädt
        for m in self.regpymods:
            importlib.reload(m)
            for name in dir(m):
                o = getattr(m, name)
                if name.startswith('_'):
                    continue
                try:
                    x = issubclass(o, IRegionModule)
                except TypeError:
                    pass
                else:
                    if x and getattr(o, 'autoload', None):
                        print('found', name)
                        regclasses.append(o)

        print('instantiating found regions')
        for klass in regclasses:
            ri = klass()
            ri.Initialise(self.scene, self.config)
            self.scene.AddModule(ri.Name, ri)
            print("register instance", ri)
            self.reginstances.append(ri)
            ri.PostInitialise()
        print('reload done')


loader = None

def sceneinit(scene, config):
    global loader
    loader = PyReloader()
    loader.Initialise(scene, config)
    loader.PostInitialise()
    loader.cmd_py_reload('', [])
