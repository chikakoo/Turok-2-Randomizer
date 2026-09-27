import random
import zipfile
import io
import os
import fnmatch
from pathlib import Path
from PIL import Image

"""
Hue shifts textures used in Turok 2 for a different experience.
Can also adjust saturation and brightness, for more cursed textures.
Note that you'll need to replace the mod files if you want to completely undo these changes!
This also includes undoing changes for any of the DIRECTORIES_TO_HUE_SHIFT directories.

How to use:
1. Place this script into your Turok 2 install (the same folder as the game's executable)
2. Locate game.kpf and extract the files into a separate folder
3. Modify the values below to your preferences 
   - IMPORTANT: Make sure GAME_DIRECTORY is the same name as the folder you extracted the game files to
4. Run the script
"""

##################################################################
# USER CONSTANTS - Modify these (remember to set GAME_DIRECTORY) #
##################################################################

GAME_DIRECTORY = "game"
"""
The directory to start look for the textures. This should be set to the name of the folder you extracted the game.kpf
files to.
"""

HUE_RANGE = 180
"""
Inclusive value between 0 and 180, representing the hue shift values that can be rolled in either direction.
For example, if set to 20, then each texture will be shifted from a random value from -20 to 20 degrees.
In general, lower values produce images that look similar to the original ones.
"""

SATURATION_RANGE = 0
"""
Inclusive value between 0 and 1000, representing the max % that
satuation can be increated or decreased.

For example, a value of 25 will adjust between -25% and 25% saturation.
A value of 100 can produce completely grayscale images.

Recommended to not go above 25 if you don't want textures to be too cursed.
Values above 100 are allowed and can become extremely cursed!
"""

BRIGHTNESS_RANGE = 0
"""
Inclusive value between 0 and 1000, representing the max % that
brightness can be increated or decreased.

For example, a value of 25 will adjust between -25% and 25% brightness.
A value of 100 can produce completely black images.

Recommended to not go above 25 if you don't want textures to be too cursed.
Values above 100 are allowed and can become extremely cursed/unplayable!
"""

REPLACE_IN_MODS_FOLDER = True
"""
Boolean value indicating whether the created images should be packaged up and placed in the MODS_DIRECTORY,
ready to be used. Otherwise, they will be placed in the specified HUE_SHIFTER_OUTPUT_DIRECTORY.
"""

MODS_DIRECTORY = "mods"
"""
The directory to use if REPLACE_IN_MODS_FOLDER is True. This will place the images into the kpf
archives, and overwrite any existing ones in them as well. It will NOT delete files that are not being shifted.
"""

HUE_SHIFTER_OUTPUT_DIRECTORY = "hue_shifter_output"
""" 
The directory to use if REPLACE_IN_MODS_FOLDER is False.
"""

DIRECTORIES_TO_HUE_SHIFT = [
    "textures", # All textures in general: terrain, walls, enemies, pickups, etc
    "gfx", # UI, icons, splash screens
    "quickwarps", # The image when warping from a checkpoint station
    "sprites" # Particle effects, blood spatters (not everything will be affected, as grayscale images are used)
]
"""
An array of directories to search for png files to hue shift.
Remove any of the directories you do not wish to include.
If you are excluding any directories and have already randomized images, you'll need to delete/replace
the corresponding kpfs to remove the previous changes.
"""

GROUPS = [
    # General textures
    ["textures/water_*", "textures/wter_*", "textures/gwter_*"], # Water animations
    ["textures/flick01_*"], # Flickering animations
    ["textures/flik01_*"],
    ["textures/flm01_*"], # Flame/explosion animations
    ["textures/flmtb01_*"],
    ["textures/firbal01_*"],
    ["textures/kaboom01_*"],
    ["textures/kaboom05_*"],
    ["textures/feld_*"], # Misc/unknown animations
    ["textures/grntrl01_*"],
    ["textures/g-shen_*"],
    
    # Level 1
    ["textures/bnfire01_*"], # Fire animation
    
    # Level 3
    ["textures/swamp_*"], # Swamp animations
    
    # Level 5
    ["textures/7-flash_*"], # Wall computer animations
    ["textures/hl2-cmp_*"],
    ["textures/hl2-dhd_*"],
    ["textures/hl2-ta_*"],
    ["textures/hl2-tb_*"],
    ["textures/hl2-tch_*"],
    ["textures/hl2-tcx_*"],
    ["textures/hl2-td_*"],
    ["textures/hl2-tf_*"],
    ["textures/hl2-tx_*"],
    ["textures/hl3-alc_*"],
    ["textures/hl3-crf_*"],
    ["textures/hplt-_*"],
    
    # Level 6
    ["textures/7-butnb_*"], # Console button animation
    ["textures/7-tv-a_*"], # TV display animation A
    ["textures/7-tv-b_*"], # TV display animation B
    ["textures/7-tv-c_*"], # TV display animation C
    ["textures/grid_*"], # Laser animation (uncolored)
]
"""
An array of arrays of file name patterns which will all get the same modification values.

Patterns are relative to GAME_DIRECTORY and should exclude .png.
Wildcards such as * and ? are supported.

If a file matches multiple groups, the first matching group is used.

This is useful for preventing flashing textures, or to group textures that should be modified in the same way.
"""

#################################################################################
# Do not modify anything beyond this point if you don't know what you're doing! #
#################################################################################

def validate():
    """
    Validates the input parameters. This currently means...
    - GAME_DIRECTORY is a valid directory
    - HUE_RANGE should be a value between 0 and 180
    - REPLACE_IN_MODS_FOLDER is a boolean

    This also validates that every directory in DIRECTORIES_TO_HUE_SHIFT exists
    """
    if not Path(GAME_DIRECTORY).is_dir():
        raise ValueError(f"GAME_DIRECTORY path does not exist (set to {GAME_DIRECTORY})")

    if not (0 <= HUE_RANGE <= 180):
        raise ValueError(f"HUE_RANGE should be an inclusive value between 0 and 180, but got {HUE_RANGE}") 

    if not (0 <= SATURATION_RANGE <= 1000):
        raise ValueError(f"SATURATION_RANGE should be an inclusive value between 0 and 1000, but got {SATURATION_RANGE}")

    if not (0 <= BRIGHTNESS_RANGE <= 1000):
        raise ValueError(f"BRIGHTNESS_RANGE should be an inclusive value between 0 and 1000, but got {BRIGHTNESS_RANGE}")

    if not (isinstance(REPLACE_IN_MODS_FOLDER, bool)):
        raise ValueError(f"REPLACE_IN_MODS_FOLDER should be a boolean (True or False), but got {REPLACE_IN_MODS_FOLDER}")

    for directory in DIRECTORIES_TO_HUE_SHIFT:
        directory_path = Path(GAME_DIRECTORY) / directory
        if not directory_path.is_dir():
            raise ValueError(f"Directory to hue shift does not exist: {directory_path}")

def get_random_modification():
    """
    Gets set of random hue/saturation/brightness values using the X_RANGE constraints.
    """
    hue_shift = random.randint(-HUE_RANGE, HUE_RANGE)
    hue_amount = round(hue_shift * 255 / 360)

    saturation_shift = random.uniform(-SATURATION_RANGE, SATURATION_RANGE) / 100
    brightness_shift = random.uniform(-BRIGHTNESS_RANGE, BRIGHTNESS_RANGE) / 100
    
    return hue_amount, saturation_shift, brightness_shift

def modify_png(input_path, modification):
    """
    Modifies the hue/saturation/brightness of a PNG image, preserving alpha.
    """
    hue_amount, saturation_shift, brightness_shift = modification
    
    # Open image and convert to RGBA to ensure an alpha channel
    img = Image.open(input_path).convert('RGBA')

    # Separate RGB and Alpha, and convert RGB to HSV
    rgb = img.convert("RGB")
    alpha = img.getchannel("A")
    h, s, v = rgb.convert("HSV").split()

    # Perform the hue/saturation/brightness shifts
    h = h.point(lambda value: (value + hue_amount) % 256)
    s = s.point(lambda value: int(max(0, min(255, value * (1 + saturation_shift)))))
    v = v.point(lambda value: int(max(0, min(255, value * (1 + brightness_shift)))))

    # Now put everything back together and return it
    shifted_rgb = Image.merge("HSV", (h, s, v)).convert("RGB")
    shifted_img = Image.merge("RGBA", (*shifted_rgb.split(), alpha))
    return shifted_img

def image_to_bytes(image):
    """
    Converts a PIL image into PNG bytes.
    """
    image_data = io.BytesIO()
    image.save(image_data, format="PNG")
    return image_data.getvalue()

def save_to_output_dir(shifted_img, image_path):
    """
    Saves the shifted image to the hue shifter output directory, in the same place as it was in the game files.
    """
    output_path = Path(HUE_SHIFTER_OUTPUT_DIRECTORY) / image_path
    output_path.parent.mkdir(parents=True, exist_ok=True)
    shifted_img.save(output_path, 'PNG')

def save_to_mods_directory(archive_name, changes):
    """
    Saves the shifted images to the mods directory, packed in the appropriate kpf.
    """
    archive_path = Path(MODS_DIRECTORY) / f"{archive_name}.kpf"
    temp_path = archive_path.with_suffix(".tmp.kpf")

    # Make sure the mods directory exists
    archive_path.parent.mkdir(parents=True, exist_ok=True)

    # If the archive already exists, copy over everything we aren't replacing first
    # Then copy in the shifted images
    # This allows us to add all the images at once as well as being able to 
    # fake overwrite images
    if archive_path.exists():
        with zipfile.ZipFile(archive_path, "r") as source:
            with zipfile.ZipFile(temp_path, "w") as destination:
                for item in source.infolist():
                    if item.filename in changes:
                        continue

                    destination.writestr(item, source.read(item.filename))

                for image_path, image_data in changes.items():
                    destination.writestr(image_path, image_data)
    # If the archive doesn't exist, create a new one and just add all the images to it
    else:
        with zipfile.ZipFile(temp_path, "w") as destination:
            for image_path, image_data in changes.items():
                destination.writestr(image_path, image_data)

    os.replace(temp_path, archive_path)

def convert_textures():
    """
    Hue shifts all PNGs in the selected game directories,
    grouped by the KPF archive.
    """
    changes = {}
    group_modifications = {}

    for directory in DIRECTORIES_TO_HUE_SHIFT:
        directory_path = Path(GAME_DIRECTORY) / directory
        
        if not directory_path.is_dir():
            raise ValueError(f"Directory to hue shift does not exist: {directory_path}")

        for file_path in directory_path.rglob("*.png"):
            image_path = file_path.relative_to(GAME_DIRECTORY)
            archive_name = image_path.parts[0]
            
            group = get_group(file_path)
            
            if group is None:
                modification = get_random_modification()
            else:
               if group not in group_modifications:
                   group_modifications[group] = get_random_modification()
               modification = group_modifications[group]

            modified_img = modify_png(file_path, modification)

            if REPLACE_IN_MODS_FOLDER:
                shifted_bytes = image_to_bytes(modified_img)
                archive_image_path = str(image_path).replace("\\", "/")
                changes.setdefault(archive_name, {})[str(archive_image_path)] = shifted_bytes
            else:
                save_to_output_dir(modified_img, image_path)

            print(f"Converting: {file_path}")

    if REPLACE_IN_MODS_FOLDER:
        for archive_name, archive_changes in changes.items():
            save_to_mods_directory(archive_name, archive_changes)
            
def get_group(file_path):
    """
    Returns the index of the group that contains the specified file,
    or None if the file does not belong to a group.
    
    Patterns are matched agains the file's path relative to GAME_DIRECTORY.
    Both / and \\ are normalized to /.
    """
    relative_path = file_path.relative_to(GAME_DIRECTORY).with_suffix("").as_posix()
    
    for group_index, group in enumerate(GROUPS):
        for pattern in group:
            if fnmatch.fnmatchcase(relative_path, pattern):
                return group_index
    
    return None

#############
# Main code #
#############
validate()
convert_textures()
print("Done shifting textures!")