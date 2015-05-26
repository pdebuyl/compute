import numpy as np
import h5py

from traits.api import HasTraits, Range, Instance, \
        on_trait_change
from traitsui.api import View, Item, Group

from mayavi.core.api import PipelineBase
from mayavi.core.ui.api import MayaviScene, SceneEditor, \
                MlabSceneModel

import vtk
output=vtk.vtkFileOutputWindow()
output.SetFileName("log.txt")
vtk.vtkOutputWindow().SetInstance(output)

datafile = h5py.File('dump_prism.h5', 'r')
obstacle = datafile['/particles/obstacle/position']
colloids = datafile['/particles/colloids/position/value']
box = datafile['/particles/obstacle/box/edges'][:]

class MyModel(HasTraits):
    idx    = Range(0, colloids.shape[0]-1, 0,mode='spinner')

    scene = Instance(MlabSceneModel, ())

    plot = Instance(PipelineBase)


    # When the scene is activated, or when the parameters are changed, we
    # update the plot.
    @on_trait_change('idx,scene.activated')
    def update_plot(self):
        x = colloids[self.idx,:,0]
        y = colloids[self.idx,:,1]
        z = colloids[self.idx,:,2]
        if self.plot is None:
            t = np.ones(len(x))
            t[0] = 100.
            self.plot = self.scene.mlab.points3d(x, y, z, t, scale_factor=1.5, scale_mode='none', colormap="jet")
            self.other_plot = self.scene.mlab.points3d(obstacle[:,0], obstacle[:,1], obstacle[:,2], scale_factor=1.5, color=(1,0,0))
            self.outline = self.scene.mlab.outline(extent=[0, box[0], 0, box[1], 0, box[2]])
        else:
            self.plot.mlab_source.set(x=x, y=y, z=z)


    # The layout of the dialog created
    view = View(Item('scene', editor=SceneEditor(scene_class=MayaviScene),
                     height=250, width=300, show_label=False),
                Group(
                        '_', 'idx',
                     ),
                resizable=True,
                )

my_model = MyModel()
my_model.configure_traits()
