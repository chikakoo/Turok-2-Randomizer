from worlds.LauncherComponents import Component, Type, components, launch

def run_client(*args: str) -> None:
    '''
    Runs the client, which will run our bridge and the game's executable.
    This is set up below to be ran when launched from the AP client.
    '''
    from .client.launch import launch_ap_turok2_client
    launch(launch_ap_turok2_client, name="Turok 2 Client", args=args)

'''
Defines the component. The function in func will be ran when the game is launched from the AP client.
'''
components.append(
    Component(
        "Turok 2 Client",
        func=run_client,
        game_name="Turok 2",
        component_type=Type.CLIENT,
        supports_uri=True,
    )
)
