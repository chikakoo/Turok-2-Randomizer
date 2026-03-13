import os
import io
import zipfile
import Utils
from worlds.Files import APPlayerContainer
from typing import TYPE_CHECKING
#TODO: import locations/item stuff needed

if TYPE_CHECKING:
    from . import Turok2World
    
class Turok2Container(APPlayerContainer):
    game: str = 'Turok 2'

    def __init__(self, patch_data: str, base_path: str, output_directory: str,
                 player=None, player_name: str = "", server: str = ""):
        self.patch_data = patch_data
        self.file_path = base_path
        container_path = os.path.join(output_directory, base_path)
        self.patch_file_ending = ".kpf"
        super().__init__(container_path, player, player_name, server)

    def write_contents(self, opened_zipfile: zipfile.ZipFile) -> None:
        """
        Writes the contents of the patch_data into rando.kpf, so the player
        can drop it off in their Turok 2 mod folder.
        """
        kpf_buffer = io.BytesIO()
        with zipfile.ZipFile(kpf_buffer, "w", zipfile.ZIP_DEFLATED) as kpf_zip:
            kpf_zip.writestr("rando/randoReplacements.txt", self.patch_data)
            
        opened_zipfile.writestr("rando.kpf", kpf_buffer.getvalue())
        super().write_contents(opened_zipfile)
        
def gen_turok2_seed(self: "Turok2World", output_directory: str):
    replacementCode = "<This will be the AngelScript code eventually>"
    mod_name = f"AP-{self.multiworld.seed_name}-P{self.player}-{self.multiworld.get_file_safe_player_name(self.player)}"
    mod_dir = os.path.join(output_directory, mod_name + "_" + Utils.__version__ + ".zip")
    mod = Turok2Container(
        replacementCode,
        mod_dir, 
        output_directory, 
        self.player,
        self.multiworld.get_file_safe_player_name(self.player))
    mod.write()